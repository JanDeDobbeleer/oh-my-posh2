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
$sl = $global:ThemeSettings #local settings