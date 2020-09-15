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

function Test-Windows {
    $PSVersionTable.Platform -ne 'Unix'
}

function Get-Home {
    # On Unix systems, $HOME comes with a trailing slash, unlike the Windows variant
    return $HOME.TrimEnd('/', '\')
}

function Test-Administrator {
    if ($PSVersionTable.Platform -eq 'Unix') {
        return (whoami) -eq 'root'
    }
    elseif ($PSVersionTable.Platform -eq 'Windows') {
        return $false #TO-DO: find out how to distinguish this one
    }
    else {
        return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    }
}

function Get-ComputerName {
    if (Test-PsCore -And -Not Test-Windows) {
        if ($env:COMPUTERNAME) {
            return $env:COMPUTERNAME
        }
        if ($env:NAME) {
            return $env:NAME
        }
        return (uname -n)
    }
    return $env:COMPUTERNAME
}

function Get-Provider {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    return $dir.Provider.Name
}

function Get-FormattedRootLocation {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    $provider = Get-Provider -dir $dir

    if ($provider -eq 'FileSystem') {
        $homedir = Get-Home
        if ($dir.Path.StartsWith($homedir)) {
            return $sl.PromptSymbols.HomeSymbol
        }
        if ($dir.Path.StartsWith('Microsoft.PowerShell.Core')) {
            return $sl.PromptSymbols.UNCSymbol
        }
        return ''
    }
    else {
        return $dir.Drive.Name
    }
}

function Test-IsVCSRoot {
    param(
        [System.String]
        $Path
    )

    return (Test-Path -LiteralPath "$($Path)\.git") -Or (Test-Path -LiteralPath "$($Path)\.hg") -Or (Test-Path -LiteralPath "$($Path)\.svn")
}

function Get-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir,

        [Parameter(Mandatory = $false)]
        [switch]
        $noHomeAbbreviation
    )

    if ($dir.path -eq "$($dir.Drive.Name):\") {
        return "$($dir.Drive.Name):"
    }

    if ($noHomeAbbreviation.IsPresent) {
        $path = $dir.path
    }
    else {
        $path = $dir.path.Replace((Get-Home), $sl.PromptSymbols.HomeSymbol)
    }
    $path = $path.Replace('\', $sl.PromptSymbols.PathSeparator)

    return $path
}

function Get-OSPathSeparator {
    return [System.IO.Path]::DirectorySeparatorChar
}

function Get-ShortPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    $provider = Get-Provider -dir $dir

    if ($provider -eq 'FileSystem') {
        # on UNIX systems, a trailing slash can be present, yet when calling $HOME there isn't one
        $path = $dir.Path.TrimEnd((Get-OSPathSeparator))
        # list known paths and their substitutes
        $knownPaths = (Get-Home), 'Microsoft.PowerShell.Core\FileSystem::'
        $result = @()
        while ($path -And -Not ($knownPaths.Contains($path))) {
            $folder = $path.Split((Get-OSPathSeparator))[-1]
            if ( (Test-IsVCSRoot -Path $path) -Or ($result.length -eq 0) -Or -Not ($path.Contains((Get-OSPathSeparator)))) {
                $result = , $folder + $result
            }
            else {
                $result = , $sl.PromptSymbols.TruncatedFolderSymbol + $result
            }
            # remove the last element
            $path = $path.TrimEnd($folder).TrimEnd((Get-OSPathSeparator))
        }
        $shortPath = $result -join $sl.PromptSymbols.PathSeparator
        $rootLocation = (Get-FormattedRootLocation -dir $dir)
        if ($rootLocation -and $shortPath) {
            return "$rootLocation$($sl.PromptSymbols.PathSeparator)$shortPath"
        }
        if ($rootLocation) {
            return $rootLocation
        }
        return $shortPath
    }
    else {
        return $dir.path.Replace((Get-FormattedRootLocation -dir $dir), '')
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
        if ($PSVersionTable.Platform -eq 'Unix') {
            $virtualEnvName = ($env:VIRTUAL_ENV -split '/')[-1]
        } elseif ($PSVersionTable.Platform -eq 'Win32NT' -or $PSEdition -eq 'Desktop') {
            $virtualEnvName = ($env:VIRTUAL_ENV -split '\\')[-1]
        } else {
            $virtualEnvName = $env:VIRTUAL_ENV
        }
        return $virtualEnvName.Trim('[\/]')
    }
    elseif ($Env:CONDA_PROMPT_MODIFIER) {
        [regex]::Match($Env:CONDA_PROMPT_MODIFIER, "^\((.*)\)").Captures.Groups[1].Value;
    }
}

function Test-NotDefaultUser($user) {
    return $null -eq $DefaultUser -or $user -ne $DefaultUser
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

function Get-BatteryInfo {
    if ($env:OS -eq 'Windows_NT' -or $IsWindows) {

        $batteryclass = Get-CimInstance win32_battery
        if (!$batteryclass) { return }
        
        $powerclass = Get-CimInstance -Class batterystatus -Namespace root\wmi
        $charge = $batteryclass.EstimatedChargeRemaining
        $connected = $powerclass.PowerOnline
        $charging = $powerclass.Charging

    } elseif ($IsLinux) {
        
        $syspath = "/sys/class/power_supply/"
        $syspathcontents = Get-ChildItem $syspath
        if (!$syspathcontents) { return }

        $powerclass = ($syspathcontents | Where-Object { $_.Name -like 'AC*' }).Name
        if ($powerclass -is [Object[]]) { $powerdevice = $syspath + $powerclass[-1] } 
        else { $powerdevice = $syspath + $powerclass }
        $connected = Get-Content "$powerdevice/online"

        $batteryclass = ($syspathcontents | Where-Object { $_.Name -like 'BAT*' }).Name
        if ($batteryclass -is [Object[]]) { $batterydevice = $syspath + $batteryclass[-1] } 
        else { $batterydevice = $syspath + $batteryclass }
        $charge = Get-Content "$batterydevice/capacity"
        $chargestatus = Get-Content "$batterydevice/status"
        if ($chargestatus -eq "Charging" -or $chargestatus -eq "Full") { $charging = 1 }
        else { $charging = 0 }

    } else { return }

    if ($connected) {
        if ($charging) { $batteryhex = 0xf583 }
        else { $batteryhex = 0xf582 }
    } else {
        [int]$level = $charge / 10
        switch ($level) {
            0 { $batteryhex = 0xf58d }
            1 { $batteryhex = 0xf579 }
            2 { $batteryhex = 0xf57a }
            3 { $batteryhex = 0xf57b }
            4 { $batteryhex = 0xf57c }
            5 { $batteryhex = 0xf57d }
            6 { $batteryhex = 0xf57e }
            7 { $batteryhex = 0xf57f }
            8 { $batteryhex = 0xf580 }
            9 { $batteryhex = 0xf581 }
            Default { $batteryhex = 0xf578 }
        }
    }
    $battery = [char]::ConvertFromUtf32($batteryhex)
    return "$charge% $battery"
}

$escapeChar = [char]27
$sl = $global:ThemeSettings #local settings
