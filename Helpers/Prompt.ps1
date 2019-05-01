<#
.SYNOPSIS
    Defines whether or not the current terminal supports ANSI characters
.DESCRIPTION
    Logic taken from posh-git that sets the $GitPromptSettings.AnsiConsole bool:
    [bool]$AnsiConsole = $Host.UI.SupportsVirtualTerminal -or ($Env:ConEmuANSI -eq "ON")
#>
function Test-IsVanillaWindow {
    $hasAnsiSupport = (Test-AnsiTerminal) -or ($Env:ConEmuANSI -eq "ON") -or ($env:PROMPT) -or ($env:TERM_PROGRAM -eq "Hyper") -or ($env:TERM_PROGRAM -eq "vscode")
    return !$hasAnsiSupport
}

function Test-AnsiTerminal {
    return $Host.UI.SupportsVirtualTerminal
}

function Test-PsCore {
    return $PSVersionTable.PSVersion.Major -gt 5
}

function Get-Home {
    # On Unix systems, $HOME comes with a trailing slash, unlike the Windows variant
    return $HOME.TrimEnd('/','\')
}

function Test-Administrator {
    if ($PSVersionTable.Platform -eq 'Unix') {
        return (whoami) -eq 'root'
    } elseif ($PSVersionTable.Platform -eq 'Windows') {
        return $false #TO-DO: find out how to distinguish this one
    } else {
        return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    }
}

function Get-ComputerName {
    if (Test-PsCore -and $PSVersionTable.Platform -ne 'Windows') {
        if ($env:COMPUTERNAME) {
            return $env:COMPUTERNAME
        } elseif ($env:NAME) {
            return $env:NAME
        } else {
            return (uname -n)
        }
    }
    return $env:COMPUTERNAME
}

function Get-Provider {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $path
    )

    return (Get-Item $path -Force).PSProvider.Name
}

function Get-Drive {
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $dir
    )

    $provider = Get-Provider -path $dir.Path

    if($provider -eq 'FileSystem') {
        $homedir = Get-Home
        if($dir.Path.StartsWith($homedir)) {
            return '~'
        }
        elseif($dir.Path.StartsWith('Microsoft.PowerShell.Core')) {
            $parts = $dir.Path.Replace('Microsoft.PowerShell.Core\FileSystem::\\','').Split('\')
            return "$($parts[0])$($sl.PromptSymbols.PathSeparator)$($parts[1])$($sl.PromptSymbols.PathSeparator)"
        }
        else {
            $root = $dir.Drive.Name
            if($root) {
                return $root + ':'
            }
            else {
                return $dir.Path.Split(':\')[0] + ':'
            }
        }
    }
    else {
        return $dir.Drive.Name
    }
}

function Test-IsVCSRoot {
    param(
        [object]
        $dir
    )

    return (Test-Path -Path "$($dir.FullName)\.git") -Or (Test-Path -Path "$($dir.FullName)\.hg") -Or (Test-Path -Path "$($dir.FullName)\.svn")
}

function Get-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    if ($dir.path -eq "$($dir.Drive.Name):\") {
        return "$($dir.Drive.Name):"
    }
    $path = $dir.path.Replace((Get-Home),'~').Replace('\', $sl.PromptSymbols.PathSeparator)
    return $path
}

function Get-ShortPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    $provider = Get-Provider -path $dir.path

    if($provider -eq 'FileSystem') {
        $result = @()
        $currentDir = Get-Item $dir.path -Force

        while( ($currentDir.Parent) -And ($currentDir.FullName -ne (Get-Home)) ) {
            if( (Test-IsVCSRoot -dir $currentDir) -Or ($result.length -eq 0) ) {
                $result = ,$currentDir.Name + $result
            }
            else {
                $result = ,$sl.PromptSymbols.TruncatedFolderSymbol + $result
            }

            $currentDir = $currentDir.Parent
        }
        $shortPath =  $result -join $sl.PromptSymbols.PathSeparator
        if ($shortPath) {
            $drive = (Get-Drive -dir $dir)
            return "$drive$($sl.PromptSymbols.PathSeparator)$shortPath"
        }
        else {
            if ($dir.path -eq (Get-Home)) {
                return '~'
            }
            return "$($dir.Drive.Name):"
        }
    }
    else {
        return $dir.path.Replace((Get-Drive -dir $dir), '')
    }
}
function Test-VirtualEnv {
    if ($env:VIRTUAL_ENV) {
        return $true
    }
    if ($Env:CONDA_PROMPT_MODIFIER) {
        return $true
    }
    return $false
}

function Get-VirtualEnvName {
    if ($env:VIRTUAL_ENV) {
        $virtualEnvName = ($env:VIRTUAL_ENV -split '\\')[-1]
        return $virtualEnvName
    } elseif ($Env:CONDA_PROMPT_MODIFIER) {
        [regex]::Match($Env:CONDA_PROMPT_MODIFIER, "^\((.*)\)").Captures.Groups[1].Value;
    }
}

function Test-NotDefaultUser($user) {
    return $DefaultUser -eq $null -or $user -ne $DefaultUser
}

function Set-CursorForRightBlockWrite {
    param(
        [int]
        $textLength
    )

    $rawUI = $Host.UI.RawUI
    $width = $rawUI.BufferSize.Width
    $space = $width - $textLength
    Write-Prompt "$escapeChar[$($space)G"
}

function Reset-CursorPosition {
    $postion = $host.UI.RawUI.CursorPosition
    $postion.X = 0
    $host.UI.RawUI.CursorPosition = $postion
}

function Set-CursorUp {
    param(
        [int]
        $lines
    )
    return "$escapeChar[$($lines)A"
}

function Set-Newline {
    return Write-Prompt "`n"
}

$escapeChar = [char]27
$sl = $global:ThemeSettings #local settings
