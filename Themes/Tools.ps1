#requires -Version 2 -Modules posh-git

function Get-VCSStatus
{
    $status = $null
    $vcs_systems = @{
        'posh-git' = 'Get-GitStatus'
        'posh-hg' = 'Get-HgStatus'
        'posh-svn' = 'Get-SvnStatus'
    }

    foreach ($key in $vcs_systems.Keys)
    {
        $module = Get-Module -Name $key
        if($module -and @($module).Count -gt 0)
        {
            $status = (Invoke-Expression -Command ($vcs_systems[$key]))
            if ($status)
            {
                $global:GitStatus = $status
                return $status
            }
        }
    }
    return $status
}


function Get-VcsInfo
{
    param
    (
        [Object]
        $status
    )

    if ($status)
    {
        $branchStatusBackgroundColor = $sl.Colors.GitDefaultColor

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking)
        #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0))
        #hg/svn flags

        if($localChanges)
        {
            $branchStatusBackgroundColor = $sl.Colors.GitLocalChangesColor
        }
        if(-not ($localChanges) -and ($status.AheadBy -gt 0))
        {
            $branchStatusBackgroundColor = $sl.Colors.GitNoLocalChangesAndAheadColor
        }

        $vcInfo = $sl.GitSymbols.BranchSymbol;
        
        $branchStatusSymbol = $null

        if (!$status.Upstream)
        {
            $branchStatusSymbol = $sl.GitSymbols.BranchUntrackedSymbol
        }
        elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0)
        {
            # We are aligned with remote
            $branchStatusSymbol = $sl.GitSymbols.BranchIdenticalStatusToSymbol
        }
        elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1)
        {
            # We are both behind and ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy) $($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.BehindBy -ge 1)
        {
            # We are behind remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.AheadBy -ge 1)
        {
            # We are ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy)"
        }
        else
        {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol = '?'
        }

        $vcInfo = $vcInfo +  (Format-BranchName -branchName ($status.Branch))

        if ($branchStatusSymbol)
        {
            $vcInfo = $vcInfo +  ('{0} ' -f $branchStatusSymbol)
        }

        if($spg.EnableFileStatus -and $status.HasIndex)
        {
            $vcInfo = $vcInfo +  $sl.BeforeIndexSymbol

            if($spg.ShowStatusWhenZero -or $status.Index.Added)
            {
                $vcInfo = $vcInfo +  "+$($status.Index.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Modified)
            {
                $vcInfo = $vcInfo +  "~$($status.Index.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Deleted)
            {
                $vcInfo = $vcInfo +  "-$($status.Index.Deleted.Count) "
            }

            if ($status.Index.Unmerged)
            {
                $vcInfo = $vcInfo +  "!$($status.Index.Unmerged.Count) "
            }

            if($status.HasWorking)
            {
                $vcInfo = $vcInfo +  "$($sl.GitSymbols.DelimSymbol) "
            }
        }

        if($spg.EnableFileStatus -and $status.HasWorking)
        {
            if($showStatusWhenZero -or $status.Working.Added)
            {
                $vcInfo = $vcInfo +  "+$($status.Working.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Modified)
            {
                $vcInfo = $vcInfo +  "~$($status.Working.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Deleted)
            {
                $vcInfo = $vcInfo +  "-$($status.Working.Deleted.Count) "
            }
            if ($status.Working.Unmerged)
            {
                $vcInfo = $vcInfo +  "!$($status.Working.Unmerged.Count) "
            }
        }

        if ($status.HasWorking)
        {
            # We have un-staged files in the working tree
            $localStatusSymbol = $sl.GitSymbols.LocalWorkingStatusSymbol
        }
        elseif ($status.HasIndex)
        {
            # We have staged but uncommited files
            $localStatusSymbol = $sl.GitSymbols.LocalStagedStatusSymbol
        }
        else
        {
            # No uncommited changes
            $localStatusSymbol = $sl.GitSymbols.LocalDefaultStatusSymbol
        }

        if ($localStatusSymbol)
        {
            $vcInfo = $vcInfo +  ('{0} ' -f $localStatusSymbol)
        }

        if ($status.StashCount -gt 0)
        {
            $vcInfo = $vcInfo +  "$($sl.GitSymbols.BeforeStashSymbol)$($status.StashCount)$($sl.GitSymbols.AfterStashSymbol) "
        }

        if ($WindowTitleSupported -and $spg.EnableWindowTitle)
        {
            if( -not $Global:PreviousWindowTitle )
            {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf -Path (Split-Path -Path $status.GitDir)
            $prefix = if ($spg.EnableWindowTitle -is [string])
            {
                $spg.EnableWindowTitle
            }
            else
            {
                ''
            }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }

        return New-Object PSObject -Property @{
            BackgroundColor = $branchStatusBackgroundColor
            VcInfo          = $vcInfo.Trim()
        }
    }
}

function Format-BranchName
{
    param
    (
        [string]
        $branchName
    )

    if($spg.BranchNameLimit -gt 0 -and $branchName.Length -gt $spg.BranchNameLimit)
    {
        $branchName = ' {0}{1} ' -f $branchName.Substring(0, $spg.BranchNameLimit), $spg.TruncatedBranchSuffix
    }
    return " $branchName "
}

function Test-IsVanillaWindow
{
    if($env:PROMPT -or $env:ConEmuANSI)
    {
        # Console
        return $false
    }
    else
    {
        # Powershell
        return $true
    }
}

function Get-Home
{
    return $HOME
}


function Get-Provider
{
    param
    (
        [string]
        $path
    )

    return (Get-Item $path).PSProvider.Name
}

function Get-Drive
{
    param
    (
        [string]
        $path
    )

    $provider = Get-Provider -path $path

    if($provider -eq 'FileSystem')
    {
        $homedir = Get-Home
        if($path -eq $homedir)
        {
            return '~'
        }
        elseif( $path.StartsWith( 'Microsoft.PowerShell.Core' ) )
        {
            $parts = $path.Replace('Microsoft.PowerShell.Core\FileSystem::\\','').Split('\')
            return "$($parts[0])$($sl.PromptSymbols.PathSeparator)$($parts[1])$($sl.PromptSymbols.PathSeparator)"
        }
        else
        {
            $root = $path.Drive.Name
            if($root)
            {
                return $root
            }
            else
            {
                return $path.Split(':\')[0] + ':'
            }
        }
    }
    else
    {
        return $path.Drive.Name
    }
}

function Test-IsVCSRoot
{
    param
    (
        [object]
        $dir
    )

    return (Test-Path -Path "$($dir.FullName)\.git") -Or (Test-Path -Path "$($dir.FullName)\.hg") -Or (Test-Path -Path "$($dir.FullName)\.svn")
}

function Get-FullPath
{
    param
    (
        [System.Management.Automation.PathInfo]
        $dir
    )

    if ($dir.path -eq "$($dir.Drive.Name):\")
    {
        return "$($dir.Drive.Name):"
    }
    $path = $dir.path.Replace($HOME,'~').Replace('\', $sl.PromptSymbols.PathSeparator)
    return $path
}

function Get-ShortPath
{
    param
    (
        [System.Management.Automation.PathInfo]
        $dir
    )

    $provider = Get-Provider -path $dir.path

    if($provider -eq 'FileSystem')
    {
        $result = @()
        $currentDir = Get-Item $dir.path

        while( ($currentDir.Parent) -And ($currentDir.FullName -ne $HOME) )
        {
            if( (Test-IsVCSRoot -dir $currentDir) -Or ($result.length -eq 0) )
            {
                $result = ,$currentDir.Name + $result
            }
            else
            {
                $result = ,$sl.PromptSymbols.TruncatedFolderSymbol + $result
            }

            $currentDir = $currentDir.Parent
        }
        $shortPath =  $result -join $sl.PromptSymbols.PathSeparator
        if ($shortPath)
        {
            $drive = (Get-Drive -path $currentDir.FullName)
            return "$drive$($sl.PromptSymbols.PathSeparator)$shortPath"
        } 
        else 
        {
            if ($dir.path -eq $HOME)
            {
                return '~'
            }
            return "$($dir.Drive.Name):"
        }
    }
    else
    {
        return $dir.path.Replace((Get-Drive -path $dir.path), '')
    }
}

function Set-CursorForRightBlockWrite
{
    param(
        [int]
        $textLength
    )
    
    $rawUI = $Host.UI.RawUI
    $width = $rawUI.BufferSize.Width
    $space = $width - $textLength
    Write-Host "$escapeChar[$($space)G" -NoNewline
}

function Save-CursorPosition
{
    Write-Host "$escapeChar[s" -NoNewline
}

function Pop-CursorPosition
{
    Write-Host "$escapeChar[u" -NoNewline
}

function Set-CursorUp
{
    param(
        [int]
        $lines
    )
    Write-Host "$escapeChar[$($lines)A" -NoNewline
}

$escapeChar = [char]27
$spg = $global:GitPromptSettings #Posh-Git settings
$sl = $global:ThemeSettings #local settings