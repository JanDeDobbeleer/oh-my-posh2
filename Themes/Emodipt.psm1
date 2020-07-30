#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # timestamp
    $prompt = Write-Prompt -Object "[ $(Get-Date -Format HH:mm:ss) ] " -ForegroundColor $sl.colors.TimestampForegroundColor

    # check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) "
    }

    # path
    $prompt += Write-Prompt -Object "$(Get-ShortPath -dir $pwd) " -ForegroundColor $sl.Colors.DriveForegroundColor

    # virtualenv
    If (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }

    # git info
    If ($status = Get-VCSStatus) {
        $vcsInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object "$($vcsInfo.VcInfo) " -ForegroundColor $vcsInfo.BackgroundColor
    }

    # with
    If ($with) {
        $prompt += Write-Prompt -Object " $($with.ToUpper()) " -ForegroundColor $sl.Colors.WithBackgroundColor
    }

    # Writes the postfixes to the prompt
    $indicatorColor = If ($lastCommandFailed) { $sl.Colors.CommandFailedIconForegroundColor } Else { $sl.Colors.PromptSymbolColor }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $indicatorColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0x1F6A6)
$sl.GitSymbols.BranchAheadStatusSymbol = [char]::ConvertFromUtf32(0x2B6B)
$sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0x2B6D)
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2705)
$sl.GitSymbols.BranchUntrackedSymbol = [char]::ConvertFromUtf32(0x274E)
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.TimestampForegroundColor = [ConsoleColor]::DarkYellow
$sl | Add-Member -NotePropertyName DoubleCommandLine -NotePropertyValue 0 -Force
