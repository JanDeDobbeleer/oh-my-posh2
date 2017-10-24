#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    
    # write # and space
    Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptHighlightColor
    # write user
    $user = [Environment]::UserName
    if (Test-NotDefaultUser($user)) {
        Write-Prompt -Object " $user" -ForegroundColor $sl.Colors.PromptHighlightColor
        # write at (devicename)
        $device = $env:computername
        Write-Prompt -Object " at" -ForegroundColor $sl.Colors.PromptForegroundColor
        Write-Prompt -Object " $device" -ForegroundColor $sl.Colors.GitDefaultColor
        # write in for folder
        Write-Prompt -Object " in" -ForegroundColor $sl.Colors.PromptForegroundColor
    }
    # write folder
    $prompt = Get-FullPath -dir $pwd
    Write-Prompt -Object " $prompt " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    # write on (git:branchname status)    
    $status = Get-VCSStatus
    if ($status) {
        $sl.GitSymbols.BranchSymbol = ''
        $themeInfo = Get-VcsInfo -status ($status)
        Write-Prompt -Object 'on git:' -ForegroundColor $sl.Colors.PromptForegroundColor
        Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $themeInfo.BackgroundColor 
    }
    # write virtualenv
    if (Test-VirtualEnv) {
        Write-Prompt -Object 'inside env:' -ForegroundColor $sl.Colors.PromptForegroundColor
        Write-Prompt -Object "$(Get-VirtualEnvName) " -ForegroundColor $themeInfo.VirtualEnvForegroundColor 
    }
    # write [time]
    $timeStamp = Get-Date -Format T
    Write-Host "[$timeStamp]" -ForegroundColor $sl.Colors.PromptForegroundColor
    # check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }
    # check the last command state and indicate if failed
    $foregroundColor = $sl.Colors.PromptHighlightColor
    If ($lastCommandFailed) {
        $foregroundColor = $sl.Colors.CommandFailedIconForegroundColor
    }

    if ($with) {
        Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $foregroundColor
}

function Get-TimeSinceLastCommit {
    return (git log --pretty=format:'%cr' -1)
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = '#'
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x279C)
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [ConsoleColor]::Red