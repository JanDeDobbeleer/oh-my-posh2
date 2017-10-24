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
        Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    $user = [Environment]::UserName
    if (Test-NotDefaultUser($user)) {
        Write-Prompt -Object "$user " -ForegroundColor $sl.Colors.PromptForegroundColor
    }

    # Writes the drive portion
    Write-Prompt -Object "$(Get-ShortPath -dir $pwd) " -ForegroundColor $sl.Colors.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        Write-Prompt -Object "git:" -ForegroundColor $sl.Colors.PromptForegroundColor
        Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $themeInfo.BackgroundColor 
    }    

    # write virtualenv
    if (Test-VirtualEnv) {
        Write-Prompt -Object 'env:' -ForegroundColor $sl.Colors.PromptForegroundColor
        Write-Prompt -Object "$(Get-VirtualEnvName) " -ForegroundColor $themeInfo.VirtualEnvForegroundColor 
    }

    if ($with) {
        Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    # Writes the postfixes to the prompt
    Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.AdminIconForegroundColor
    Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.GitNoLocalChangesAndAheadColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
