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
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptHighlightColor
    # write user
    $user = $sl.CurrentUser
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object " $user" -ForegroundColor $sl.Colors.PromptForegroundColor
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
        $sl.GitSymbols.BranchSymbol = ''
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object 'on git:' -ForegroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $sl.Colors.GitForegroundColor
    }
    # write [time]
    $timeStamp = Get-Date -Format T
    $prompt += Write-Prompt "[$timeStamp]" -ForegroundColor $foregroundColor
    # new line
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.PromptForegroundColor
    $prompt += ' '
    $prompt
}
$sl = $global:ThemeSettings    # local settings
$sl.PromptSymbols.StartSymbol                = '#'

# for non-powerline fonts
$sl.PromptSymbols.PromptIndicator            = '%'
If (Test-Administrator) {
        $sl.PromptSymbols.PromptIndicator    = '$'
    }

#              BranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)  # 0xE0A0, Version Control Branch 
#              BranchUntrackedSymbol         = [char]::ConvertFromUtf32(0x2262)  # 0x2262, Not Identical To 
#              BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2263)  # 0x2263, Strictly Equivalent To 
$sl.GitSymbols.BranchUntrackedSymbol         = 'x'                               #
$sl.GitSymbols.BranchIdenticalStatusToSymbol = 'o'                               #

#                 PromptIndicator            = [char]::ConvertFromUtf32(0x25B6)  # 0x25B6, Black Right-Pointing Triangle 
#                 FailedCommandSymbol        = [char]::ConvertFromUtf32(0x2A2F)  # 0x2A2F, Vector Or Cross Product 
#                 ElevatedSymbol             = [char]::ConvertFromUtf32(0x26A1)  # 0x26A1, High Voltage Sign 
$sl.PromptSymbols.FailedCommandSymbol        = '?'                               #

#
# inspired by ys theme： not to use special characters (powerline fonts).
# >[https://blog.ysmood.org/my-ys-terminal-theme/]()
# 