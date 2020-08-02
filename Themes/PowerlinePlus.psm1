#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $user = $sl.CurrentUser
    $computer = [System.Environment]::MachineName
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer" -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $path = (Get-ShortPath -dir $pwd).Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor -BackgroundColor $sl.Colors.WithBackgroundColor
        $prompt += Write-Prompt -Object " $($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
        $lastColor = $sl.Colors.WithBackgroundColor
    }
    If ($lastCommandFailed) {
	$errsign = "!".Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $ErrBackground
	$prompt += Write-Prompt -Object $errsign -ForegroundColor $ErrForeground -BackgroundColor $ErrBackground
	$lastColor = $ErrBackground
    }

 If (Test-Administrator) {
	$rootsign = "#".Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $RootBackground
	$prompt += Write-Prompt -Object $rootsign -ForegroundColor $RootForeground -BackgroundColor $RootBackground
	$prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $RootBackground -BackgroundColor $sl.Colors.SessionInfoForegroundColor
	}
	else {
	$norootsign = "$".Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
	$prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $ReguserBackground
	$prompt += Write-Prompt -Object $norootsign -ForegroundColor $ReguserForeground -BackgroundColor $ReguserBackground
	$prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $ReguserBackground -BackgroundColor $sl.Colors.SessionInfoForegroundColor
	}

    # Writes the postfix to the prompt
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::Cyan
$sl.Colors.SessionInfoForegroundColor = [ConsoleColor]::Black
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$RootBackground = [ConsoleColor]::Magenta
$RootForeground = [ConsoleColor]::White
$ReguserBackground = [ConsoleColor]::Blue
$ReguserForeground = [ConsoleColor]::White
$ErrForeground = [ConsoleColor]::White
$ErrBackground = [ConsoleColor]::DarkRed
