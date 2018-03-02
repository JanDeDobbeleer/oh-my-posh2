#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor

    $dir = Get-FullPath -dir $pwd

    $prompt += Write-Prompt -Object $dir -ForegroundColor $sl.Colors.PromptForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $vcsInfo = Get-VcsInfo -status ($status)
        $info = $vcsInfo.VcInfo
        $prompt += Write-Prompt -Object " $info" -ForegroundColor $vcsInfo.BackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.ElevatedSymbol)" -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.FailedCommandSymbol)" -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    $timeStamp = Get-Date -Format T
    $clock = [char]::ConvertFromUtf32(0x25F7)
    $timestamp = "$clock $timeStamp"

    if ($status) {
        $timeStamp = Get-TimeSinceLastCommit
    }

    $prompt += Set-CursorForRightBlockWrite -textLength $timestamp.Length
    $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.PromptBackgroundColor
    $prompt += Set-Newline

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.PromptBackgroundColor
    $prompt += ' '
    $prompt
}

function Get-TimeSinceLastCommit {
    return (git log --pretty=format:'%cr' -1)
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x25B6)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::Red