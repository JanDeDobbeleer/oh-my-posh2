#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt = Write-Prompt -Object "Don't Panic!" -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    $prompt += Set-Newline

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    $status = Get-VCSStatus
    if ($status) {
        $prompt += Write-Prompt -Object "$($status.Branch)$([char]::ConvertFromUtf32(0xE0A0)) " -ForegroundColor $themeInfo.BackgroundColor
    }

    # write virtualenv
    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$(Get-VirtualEnvName)" -ForegroundColor $themeInfo.VirtualEnvForegroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object " $(Get-FullPath -dir $pwd)" -ForegroundColor $sl.Colors.DriveForegroundColor

    # Writes the postfixes to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.DriveForegroundColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
