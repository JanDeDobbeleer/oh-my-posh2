#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    # check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
        $prompt += ' '
    }
    # write # and space
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptStartSymbolColor
    # write user and host
    $user = $sl.CurrentUser
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object " $user" -ForegroundColor $sl.Colors.PromptHighlightColor
        # write at (devicename)
        $computer = $sl.CurrentHostname
        $prompt += Write-Prompt -Object " at" -ForegroundColor $foregroundColor
        $prompt += Write-Prompt -Object " $computer" -ForegroundColor $sl.Colors.PromptForegroundColor
        # write in for folder
        $prompt += Write-Prompt -Object " in" -ForegroundColor $foregroundColor
    }
    # write folder
    $dir = Get-FullPath -dir $pwd
    $prompt += Write-Prompt -Object " $dir " -ForegroundColor $sl.Colors.GitDefaultColor
    # write on (git:branchname status)
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object 'on git:' -ForegroundColor $foregroundColor
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $sl.Colors.GitForegroundColor
    }
    # write [time]
    $timeStamp = Get-Date -Format T
    $prompt += Write-Prompt "[$timeStamp]" -ForegroundColor $foregroundColor
    # new line
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator + " ") -ForegroundColor $sl.Colors.PromptSymbolColor

}

$sl = $global:ThemeSettings # local settings
$sl.PromptSymbols.StartSymbol                = '#'
$sl.PromptSymbols.PromptIndicator            = '%'
If (Test-Administrator) {
        $sl.PromptSymbols.PromptIndicator    = '$'
    }
$sl.GitSymbols.BranchSymbol                  = ''
$sl.GitSymbols.BranchUntrackedSymbol         = 'x'
$sl.GitSymbols.BranchIdenticalStatusToSymbol = 'o'
$sl.PromptSymbols.FailedCommandSymbol        = '?'

# for dark theme
$sl.Colors.PromptStartSymbolColor =  [ConsoleColor]::Blue
$sl.Colors.PromptSymbolColor      = [ConsoleColor]::Red
$sl.Colors.PromptForegroundColor  = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor   = [ConsoleColor]::Cyan
$sl.Colors.GitDefaultColor        = [ConsoleColor]::Yellow
$sl.Colors.GitForegroundColor     = [ConsoleColor]::Cyan

# inspired by ys theme： not to use special characters (powerline fonts).
# >[https://blog.ysmood.org/my-ys-terminal-theme/]()
