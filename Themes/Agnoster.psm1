#requires -Version 2 -Modules posh-git

function Write-Theme {
    
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor

    Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $computer = $env:computername
    if (Test-NotDefaultUser($user)) {
        Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    
    if (Test-VirtualEnv) {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    Write-Prompt -Object (Get-ShortPath -dir $pwd) -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    Write-Prompt -Object ' ' -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor        
    }

    if ($with) {
        Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor -BackgroundColor $sl.Colors.WithBackgroundColor
        Write-Prompt -Object " $($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
        $lastColor = $sl.Colors.WithBackgroundColor
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White