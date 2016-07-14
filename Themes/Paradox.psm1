#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )
    
    $fancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B0)
      
    $lastColor = $sl.PromptBackgroundColor
    $prompt = ' '
    # PowerLine starts with a space
    Write-Prompt -Object $prompt -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        $prompt = $prompt + "$($sl.FailedCommandSymbol) "
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        $prompt = $prompt + "$($sl.ElevatedSymbol) "
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $path = (Get-Location).Path.Replace($HOME,'~')
    
    $prompt = $prompt + "$user $fancySpacerSymbol $path "
    Write-Prompt -Object "$user " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    Write-Prompt -Object "$fancySpacerSymbol " -ForegroundColor $sl.SessionInfoBackgroundColor -BackgroundColor $sl.PromptBackgroundColor

    # Writes the drive portion
    Write-Prompt -Object "$path " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt = $prompt + $fancySpacerSymbol + " $($themeInfo.VcInfo) "
        Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $lastColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.PromptForegroundColor        
    }

    # Writes the postfix to the prompt
    $prompt = $prompt + $fancySpacerSymbol
    Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $lastColor

    $timeStamp = Get-Date -UFormat %r
    $timestamp = "[$timeStamp]"

    $remainingWidth = Get-BetweenSpace -promptText $prompt -endText $timeStamp

    Write-Host $timeStamp.PadLeft($remainingWidth -1, ' ').PadLeft(1, ' ') -ForegroundColor $sl.PromptForegroundColor 

    $promptSymbol = [char]::ConvertFromUtf32(0x276F)
    Write-Prompt -Object " $promptSymbol" -ForegroundColor $sl.PromptBackgroundColor
}

$sl = $global:ThemeSettings #local settings
