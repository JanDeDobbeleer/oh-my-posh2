#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    $drive = $sl.PromptSymbols.HomeSymbol
    if ($pwd.Path -ne $HOME) {
        $drive = "$(Split-Path -path $pwd -Leaf)"
    }
    $prompt += Write-Prompt -Object $drive -ForegroundColor $sl.Colors.PromptForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object " ::" -ForegroundColor $sl.Colors.AccentColor
        $prompt += Write-Prompt -Object " $($status.Branch)" -ForegroundColor $lastColor
    }

   

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.FailedCommandSymbol)" -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.VirtualEnvSymbol)" -ForegroundColor $sl.Colors.AccentColor
        $prompt += Write-Prompt -Object " $(Get-VirtualEnvName)" -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }
    if ($with) {
        $prompt += Write-Prompt -Object " *" -ForegroundColor $sl.Colors.AccentColor
        $prompt += Write-Prompt -Object " $($with.ToUpper())" -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Write-Prompt -Object (" " + $sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.AccentColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276f)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Cyan
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.AccentColor = [System.ConsoleColor]::DarkGray

