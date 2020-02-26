#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $prompt = Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.Colors.PromptSymbolColor
    $user = $sl.CurrentUser
    $computer = $sl.CurrentHostname
    $prompt += Write-Segment -content "$user@$computer" -foregroundColor $sl.Colors.PromptForegroundColor

    # $prompt += "$($sl.PromptSymbols.SegmentForwardSymbol) "

    $status = Get-VCSStatus
    if ($status) {
        $vcsInfo = Get-VcsInfo -status ($status)
        $info = $vcsInfo.VcInfo
        $prompt += Write-Segment -content $info -foregroundColor $sl.Colors.GitForegroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Segment -content $sl.PromptSymbols.ElevatedSymbol -foregroundColor $sl.Colors.AdminIconForegroundColor
    }

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Segment -content $sl.PromptSymbols.FailedCommandSymbol -foregroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    $prompt += ''

    # SECOND LINE
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.PromptSymbolColor
    $path += Get-FullPath -dir $pwd
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.PromptForegroundColor

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) $($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName)" -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) $($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColor
        $prompt += Write-Prompt -Object "$($with.ToUpper())" -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)$($sl.PromptSymbols.PromptIndicator)" -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt
}

function Write-Segment {

    param(
        $content,
        $foregroundColor
    )

    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += Write-Prompt -Object $content -ForegroundColor $foregroundColor
    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.PromptSymbolColor
    return $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = '>'
$sl.PromptSymbols.SegmentForwardSymbol = ']'
$sl.PromptSymbols.SegmentBackwardSymbol = '['
$sl.PromptSymbols.PathSeparator = '\'
$sl.PromptSymbols.FailedCommandSymbol = 'x'
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::DarkRed
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::White
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkYellow
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
