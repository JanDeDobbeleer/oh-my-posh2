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
        $prompt = Write-Prompt -Object "Don't Panic! " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    $prompt += Set-Newline

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    $user = $sl.CurrentUser
    if (Test-NotDefaultUser($user)) {
        #$prompt += Write-Prompt -Object "$user " -ForegroundColor $sl.Colors.PromptForegroundColor
    }

    # write virtualenv
    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$(Get-VirtualEnvName)" -ForegroundColor $themeInfo.VirtualEnvForegroundColor
    }

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo)" -ForegroundColor $themeInfo.BackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object " $(Get-FullPath -dir $pwd)" -ForegroundColor $sl.Colors.DriveForegroundColor


    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper())" -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

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
