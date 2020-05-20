#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # path
    $sPath = "$(Get-FullPath -dir $pwd) "
    #$getStackContext = {Get-Location -Stack}
    #$stackCount = (&$getStackContext).count

    # check for elevated prompt
    $sAdmin = ""
    If (Test-Administrator) {
        $sAdmin = " $($sl.PromptSymbols.ElevatedSymbol)"
    }

    # timestamp
    $sTime = " $(Get-Date -Format HH:mm:ss)"

    # check the last command state and indicate if failed
    $sFailed = ""
    If ($lastCommandFailed) {
        $sFailed = " $($sl.PromptSymbols.FailedCommandSymbol)"
    }

    # virtualenv
    $sVenv = ""
    If (Test-VirtualEnv) {
        $sVenv = " $(Get-VirtualEnvName)"
    }

    # with
    $sWith = ""
    If ($with) {
        $sWith = " $($with.ToUpper())"
    }

    $rightPrompt = "$sFailed$sWith$sVenv$sAdmin$sTime"
    $prompt += Set-CursorForRightBlockWrite -textLength $rightPrompt.Length
    $prompt += Write-Prompt -Object $sFailed -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    $prompt += Write-Prompt -Object $sWith   -ForegroundColor $sl.Colors.WithForegroundColor

    $prompt += Write-Prompt -Object $sVenv   -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    $prompt += Write-Prompt -Object $sAdmin  -ForegroundColor $sl.Colors.AdminIconForegroundColor
    $prompt += Write-Prompt -Object $sTime   -ForegroundColor $sl.colors.TimestampForegroundColor
    $prompt += Write-Prompt -Object "`r"

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt -Object " $($sPath)" -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $lastColor


    # git info
    $vcsStatus = Get-VCSStatus
    if ($vcsStatus) {
        $vcsInfo = Get-VcsInfo -status ($vcsStatus)
        $lastColor = $vcsInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($vcsInfo.VcInfo) " -ForegroundColor $sl.Colors.GitForegroundColor -BackgroundColor $lastColor
    }
    

    If ($sl.DoubleCommandLine) {
        $prompt += Set-Newline
    }

    # Writes the postfixes to the prompt
    $indicatorColor = If ($lastCommandFailed) { $sl.Colors.CommandFailedIconForegroundColor } Else { $lastColor }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $indicatorColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)

$sl.Colors.DriveForegroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitDefaultColor = [ConsoleColor]::DarkGreen
$sl.Colors.GitLocalChangesColor = [ConsoleColor]::DarkYellow
$sl.Colors.GitNoLocalChangesAndAheadAndBehindColor = [ConsoleColor]::DarkRed
$sl.Colors.GitNoLocalChangesAndAheadColor = [ConsoleColor]::DarkMagenta
$sl.Colors.GitNoLocalChangesAndBehindColor = [ConsoleColor]::DarkRed
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::Black
$sl.Colors.SessionInfoForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [ConsoleColor]::Red


$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.GitForegroundColor = [ConsoleColor]::DarkGray
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.TimestampForegroundColor = [ConsoleColor]::DarkCyan
$sl.Colors.CommandFailedIconForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.AdminIconForegroundColor = [ConsoleColor]::DarkYellow
$sl.Colors.PromptBackgroundColor = [ConsoleColor]::DarkBlue



$sl | Add-Member -NotePropertyName DoubleCommandLine -NotePropertyValue 0 -Force
