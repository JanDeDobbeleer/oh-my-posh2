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
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptSymbolColor
    # write user
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
        $prompt += Write-Prompt -Object 'on git:' -ForegroundColor $sl.Colors.foregroundColor
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $sl.Colors.GitForegroundColor
    }
    # write [time]
    $timeStamp = Get-Date -Format T
    $prompt += Write-Prompt "[$timeStamp]" -ForegroundColor $sl.Colors.PromptSymbolColor
    # new line
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt
}
$sl = $global:ThemeSettings    # local settings
$sl.PromptSymbols.StartSymbol                = '#'

# === for non-powerline fonts : ys ===============================
# [https://blog.ysmood.org/my-ys-terminal-theme/]()
$sl.PromptSymbols.PromptIndicator            = '%'
If (Test-Administrator) {
    $sl.PromptSymbols.PromptIndicator        = '$'
}
$sl.GitSymbols.BranchSymbol                  = ''
$sl.GitSymbols.BranchUntrackedSymbol         = 'x'
$sl.GitSymbols.BranchIdenticalStatusToSymbol = 'o'
$sl.PromptSymbols.FailedCommandSymbol        = '?'

# === for non-powerline fonts : yahei ===============================
$sl.PromptSymbols.PromptIndicator            = '>'
If (Test-Administrator) {
    $sl.PromptSymbols.PromptIndicator        = [char]::ConvertFromUtf32(0x00BB)  # 0x00BB, Right-Pointing Double Angle Quotation Mark, 双大于号
}
$sl.GitSymbols.BranchSymbol                  = ''
$sl.GitSymbols.BranchUntrackedSymbol         = [char]::ConvertFromUtf32(0x2260)  # 0x2260, Not Equal To， 不等号（两条横线一条斜线）
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2261)  # 0x2261, Identical To， 等同于（三条横线）
$sl.PromptSymbols.FailedCommandSymbol        = '?'

# === for non-powerline fonts : jetbrains ===============================
$sl.PromptSymbols.PromptIndicator            = '>'
If (Test-Administrator) {
    $sl.PromptSymbols.PromptIndicator        = [char]::ConvertFromUtf32(0x27E9)  # 0x27E9, Mathematical Right Angle Bracket，数学直角右括号
}
$sl.GitSymbols.BranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)  # 0xE0A0, Version Control Branch, 版本控制符号
$sl.GitSymbols.BranchUntrackedSymbol         = [char]::ConvertFromUtf32(0x2260)  # 0x2260, Not Equal To， 不等号（两条横线一条斜线）
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2261)  # 0x2261, Identical To， 等同于（三条横线）
$sl.PromptSymbols.FailedCommandSymbol        = '?'

# === for light theme ======================================================
# concfg import google-light
$sl.Colors.PromptForegroundColor             = [ConsoleColor]::Yellow
$sl.Colors.PromptHighlightColor              = [ConsoleColor]::Cyan
$sl.Colors.PromptSymbolColor                 = [ConsoleColor]::DarkGray
$sl.Colors.GitDefaultColor                   = [ConsoleColor]::Red
$sl.Colors.GitForegroundColor                = [ConsoleColor]::Magenta
$sl.Colors.CommandFailedIconForegroundColor  = [ConsoleColor]::DarkGray

# === for dark theme ======================================================= 
# concfg import vs-code-dark-plus
$sl.Colors.PromptHighlightColor              = [ConsoleColor]::DarkBlue
$sl.Colors.PromptForegroundColor             = [ConsoleColor]::Blue
$sl.Colors.PromptSymbolColor                 = [ConsoleColor]::Magenta
$sl.Colors.GitDefaultColor                   = [ConsoleColor]::Green
$sl.Colors.GitForegroundColor                = [ConsoleColor]::DarkGreen
$sl.Colors.CommandFailedIconForegroundColor  = [ConsoleColor]::DarkRed
