#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #check the last command state and indicate if failed
    $promtSymbolColor = $sl.Colors.PromptSymbolColor
    If ($lastCommandFailed) {
        $promtSymbolColor = $sl.Colors.WithForegroundColor
    }

    # Writes the drive portion
    $drive = Get-FullPath -dir $pwd
    $prompt += Write-Prompt -Object $drive -ForegroundColor $sl.Colors.DriveForegroundColor

    $prompt += Write-Prompt -Object ' '

    $status = Get-VCSStatus
    if ($status) {
        $prompt += Write-Prompt -Object "$($status.Branch)" -ForegroundColor $sl.Colors.WithForegroundColor
        if ($status.Working.Length -gt 0) {
            $prompt += Write-Prompt -Object (" " + $sl.PromptSymbols.GitDirtyIndicator) -ForegroundColor $sl.Colors.GitDefaultColor
        }
    }

    # New line
    $prompt += Set-Newline

    # Writes the postfixes to the prompt
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $promtSymbolColor

    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276f)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Blue
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.PromptSymbols.GitDirtyIndicator = [char]::ConvertFromUtf32(10007)
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow
