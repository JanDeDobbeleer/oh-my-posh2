#requires -Version 2 -Modules posh-git

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $fancySpacerSymbol = $sl.FancySpacerSymbol 
    $drive = (Get-Drive -path (Get-Location).Path)
    $location = (Get-ShortPath -path (Get-Location).Path)
    # remove the trailing slash for the HOME folder
    if ($location -eq '' -and $drive -eq '~\')
    {
        $drive = '~'
    }

    $lastColor = $sl.PromptBackgroundColor

    # PowerLine starts with a space
    Write-Prompt -Object ' ' -ForegroundColor $sl.SessionInfoForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $computer = $env:computername
    Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.SessionInfoForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    Write-Prompt -Object "$fancySpacerSymbol " -ForegroundColor $sl.SessionInfoBackgroundColor -BackgroundColor $sl.PromptBackgroundColor

    # Writes the drive portion
    Write-Prompt -Object "$drive" -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    Write-Prompt -Object (Get-ShortPath -path (Get-Location).Path) -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    Write-Prompt -Object ' ' -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $lastColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.GitForegroundColor
    }

    if ($with)
    {
        Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $lastColor -BackgroundColor $sl.WithBackgroundColor
        Write-Prompt -Object " $($with.ToUpper()) " -BackgroundColor $sl.WithBackgroundColor -ForegroundColor $sl.WithForegroundColor
        $lastColor = $sl.WithBackgroundColor
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $lastColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptForegroundColor = [ConsoleColor]::White
$sl.PromptSymbolColor = [ConsoleColor]::White
$sl.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.GitForegroundColor = [ConsoleColor]::Black
$sl.WithForegroundColor = [ConsoleColor]::White
$sl.WithBackgroundColor = [ConsoleColor]::DarkRed
