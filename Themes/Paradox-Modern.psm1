#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    
    $prompt += Set-Newline
    
    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = $sl.CurrentUser
    $computer = $sl.CurrentHostname
    $pathSymbol = if ($pwd.Path -eq $HOME) { $sl.PromptSymbols.PathHomeSymbol } else { $sl.PromptSymbols.PathSymbol }
    $path = $pathSymbol + " " + (Get-FullPath -dir $pwd)

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    $timeStamp = Get-Date -Format "hh:mm tt"
    $timestamp = " $timeStamp "

    if ($host.UI.RawUI.CursorPosition.X + $timestamp.Length + 9 -lt $host.UI.RawUI.WindowSize.Width){
        $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 9)
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur1Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur2Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur3Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.GitForegroundColor -BackgroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ClockSymbol) " -ForegroundColor $sl.Colors.GitForegroundColor -BackgroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur3Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur2Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur1Symbol -ForegroundColor $PromptForegroundColor
    }
    $prompt += Set-Newline


    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor
    }
    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.Blur1Symbol = [char]::ConvertFromUtf32(0x2591)
$sl.PromptSymbols.Blur2Symbol = [char]::ConvertFromUtf32(0x2592)
$sl.PromptSymbols.Blur3Symbol = [char]::ConvertFromUtf32(0x2593)
$sl.PromptSymbols.ClockSymbol = [char]::ConvertFromUtf32(0xf64f)
$sl.PromptSymbols.PathHomeSymbol = [char]::ConvertFromUtf32(0xf015)
$sl.PromptSymbols.PathSymbol = [char]::ConvertFromUtf32(0xf07c)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
