#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )

    $prompt = (Get-Location).Path.Replace($HOME,'~')
    if ($prompt -eq '~')
    {
        $prompt = $prompt + '\'
    }

    Write-Prompt -Object $prompt -ForegroundColor $sl.PromptForegroundColor
    
    $status = Get-VCSStatus
    if ($status)
    {
        $vcsInfo = Get-VcsInfo -status ($status)
        $info = $vcsInfo.VcInfo
        $prompt = $prompt + " $info"
        Write-Prompt -Object " $info" -ForegroundColor $vcsInfo.BackgroundColor
    }
    
    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        $prompt = $prompt + " $($sl.ElevatedSymbol)"
        Write-Prompt -Object " $($sl.ElevatedSymbol)" -ForegroundColor $sl.AdminIconForegroundColor
    }

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        $prompt = $prompt + " $($sl.FailedCommandSymbol)"
        Write-Prompt -Object " $($sl.FailedCommandSymbol)" -ForegroundColor $sl.CommandFailedIconForegroundColor
    }

    $timeStamp = Get-Date -Format T
    $clock = [char]::ConvertFromUtf32(0x25F7)
    $timestamp = "$clock $timeStamp"

    if ($status)
    {
        $timeStamp = Get-TimeSinceLastCommit
    }

    $remainingWidth = Get-BetweenSpace -promptText $prompt -endText $timeStamp

    Write-Host $timeStamp.PadLeft($remainingWidth -1, ' ').PadLeft(1, ' ') -ForegroundColor $sl.PromptBackgroundColor
    $promptSymbol = [char]::ConvertFromUtf32(0x25B6)
    Write-Prompt -Object "$promptSymbol" -ForegroundColor $sl.PromptBackgroundColor
}

function Get-TimeSinceLastCommit
{
    return (git log --pretty=format:'%cr' -1)
}

$sl = $global:ThemeSettings #local settings
