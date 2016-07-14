#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )
    
    $drive = (Get-Drive -path (Get-Location).Path)

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor
    }

    $user = [Environment]::UserName
    Write-Prompt -Object "$user " -ForegroundColor $sl.PromptForegroundColor

    # Writes the drive portion
    Write-Prompt -Object "$drive" -ForegroundColor $sl.DriveForegroundColor
    Write-Prompt -Object (Get-ShortPath -path (Get-Location).Path) -ForegroundColor $sl.DriveForegroundColor
    Write-Prompt -Object ' ' -ForegroundColor $sl.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $themeInfo = Get-VcsInfo -status ($status)
        Write-Prompt -Object "git:" -ForegroundColor $sl.PromptForegroundColor
        Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $themeInfo.BackgroundColor 
    }

    # Writes the postfixes to the prompt
    $forwardSpacerSymbol = [char]::ConvertFromUtf32(0x276F)
    Write-Prompt -Object $forwardSpacerSymbol -ForegroundColor $sl.CommandFailedIconForegroundColor
    Write-Prompt -Object $forwardSpacerSymbol -ForegroundColor $sl.AdminIconForegroundColor
    Write-Prompt -Object $forwardSpacerSymbol -ForegroundColor $sl.GitNoLocalChangesAndAheadColor
}

$sl = $global:ThemeSettings #local settings
