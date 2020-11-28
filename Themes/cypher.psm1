#requires -Version 2 -Modules posh-git

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $user = $sl.CurrentUser
    $prompt = Write-Prompt -Object ("$user ") -ForegroundColor $sl.Colors.UsernameForegroundColor
    $prompt += Write-Prompt -Object (":: ") -ForegroundColor $sl.Colors.SeparatorForegroundColor

    $drive = $sl.PromptSymbols.HomeSymbol
    if ($pwd.Path -ne $HOME) {
        $drive = "$(Split-Path -path $pwd -Leaf)"
    }
    $prompt += Write-Prompt -Object ($drive + " ") -ForegroundColor $sl.Colors.DriveForegroundColor

    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.PromptForegroundColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x00BB)
$sl.Colors.UsernameForegroundColor = [ConsoleColor]::Blue
$sl.Colors.SeparatorForegroundColor = [ConsoleColor]::Red
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Green
$sl.Colors.PromptForegroundColor = [ConsoleColor]::Magenta