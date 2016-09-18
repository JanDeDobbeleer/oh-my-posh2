#requires -Version 2 -Modules posh-git

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # Create the right block first, set to 1 line up on the right
    Save-CursorPosition
    $backwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B2)
    $betweenBackwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B3)
    $date = Get-Date -UFormat %d-%m-%Y
    $timeStamp = Get-Date -UFormat %R

    $leftText = "$backwardSpacerSymbol $date $betweenBackwardSpacerSymbol $timeStamp "
    Set-CursorUp -lines 1
    Set-CursorForRightBlockWrite -textLength $leftText.Length

    Write-Prompt -Object "$backwardSpacerSymbol" -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $sl.PromptHighlightColor
    Write-Prompt " $date $betweenBackwardSpacerSymbol $timeStamp " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    Pop-CursorPosition

    $fancySpacerSymbol = $sl.FancySpacerSymbol
    $betweenBackwardSpacerSymbol = $sl.BetweenFancySpacerSymbol

    # Write the prompt
    Write-Prompt -Object ' ' -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    # Check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $computer = $env:computername
    $path = (Get-Location).Path.Replace($HOME,'~')

    Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.SessionInfoForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    Write-Prompt -Object "$fancySpacerSymbol " -ForegroundColor $sl.SessionInfoBackgroundColor -BackgroundColor $sl.PromptBackgroundColor

    # Writes the drive portion
    Write-Prompt -Object "$path " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $themeInfo = Get-VcsInfo -status ($status)
        Write-Prompt -Object $betweenFancySpacerSymbol -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    }

    if ($with)
    {
        Write-Prompt -Object $betweenFancySpacerSymbol -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
        Write-Prompt -Object " $($with.ToUpper()) " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbolColor = [ConsoleColor]::White
$sl.PromptForegroundColor = [ConsoleColor]::White
$sl.PromptHighlightColor = [ConsoleColor]::Magenta
$sl.GitForegroundColor = [ConsoleColor]::Black
$sl.WithForegroundColor = [ConsoleColor]::White
$sl.WithBackgroundColor = [ConsoleColor]::DarkRed
