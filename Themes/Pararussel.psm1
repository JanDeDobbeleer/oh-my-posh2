#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #check the last command state and indicate if failed and change the colors of the arrows
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object (
            [char]::ConvertFromUtf32(0x276F)) -ForegroundColor  $sl.Colors.WithForegroundColor
        $prompt += Write-Prompt -Object (
            [char]::ConvertFromUtf32(0x276F) +"  ") -ForegroundColor $sl.Colors.WithForegroundColor
    }Else{
        $prompt += Write-Prompt -Object (
            [char]::ConvertFromUtf32(0x276F)) -ForegroundColor  $sl.Colors.GitNoLocalChangesAndAheadColor
        $prompt += Write-Prompt -Object (
            [char]::ConvertFromUtf32(0x276F) +"  ") -ForegroundColor $sl.Colors.PromptSymbolColor
    }
    

    # Writes the drive portion
    $drive = $sl.PromptSymbols.HomeSymbol
    if ($pwd.Path -ne $HOME) {
        $drive = "$(Split-Path -path $pwd -Leaf)"
    }
    $prompt += Write-Prompt -Object $drive -ForegroundColor $sl.Colors.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $prompt += Write-Prompt -Object " git:(" -ForegroundColor $sl.Colors.PromptHighlightColor
        $prompt += Write-Prompt -Object "$($status.Branch)" -ForegroundColor $sl.Colors.WithForegroundColor
        $prompt += Write-Prompt -Object ")" -ForegroundColor $sl.Colors.PromptHighlightColor
        if ($status.Working.Length -gt 0) {
            $prompt += Write-Prompt -Object (" " + $sl.PromptSymbols.GitDirtyIndicator) -ForegroundColor $sl.Colors.GitDefaultColor
        }
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $timeStamp = Get-Date -UFormat %R
    $clock = [char]::ConvertFromUtf32(0x25F7)
    $timestamp = "$clock $timeStamp"

    if ($status) {
        $timeStamp = Get-TimeSinceLastCommit
    }
    $prompt += Set-CursorForRightBlockWrite -textLength $timestamp.Length
    $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.DriveForegroundColor
    $prompt += Set-Newline

    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptBackgroundColor
    
    $prompt += '  '
    $prompt
}

function Get-TimeSinceLastCommit {
    return (git log --pretty=format:'%cr' -1)
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x1F441)
$sl.PromptSymbols.HomeSymbol = [char]::ConvertFromUtf32(0x1F3E0)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Blue
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.PromptSymbols.GitDirtyIndicator = [char]::ConvertFromUtf32(0x1F4CC)
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow
