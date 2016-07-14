#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )
    
    Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.PromptSymbolColor
    Write-Segment -content ([Environment]::UserName) -foregroundColor $sl.PromptForegroundColor

    $prompt = "$user] "

    $status = Get-VCSStatus
    if ($status)
    {
        $vcsInfo = Get-VcsInfo -status ($status)
        $info = $vcsInfo.VcInfo
        Write-Segment -content $info -foregroundColor $sl.PromptForegroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Write-Segment -content $sl.ElevatedSymbol -foregroundColor $sl.AdminIconForegroundColor
    }

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        Write-Segment -content $sl.FailedCommandSymbol -foregroundColor $sl.CommandFailedIconForegroundColor
    }

    Write-Host ''

    # SECOND LINE
    Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.PromptSymbolColor
    $prompt = (Get-Location).Path.Replace($HOME,'~')
    if ($prompt -eq '~')
    {
        $prompt = $prompt + '\'
    }

    Write-Prompt -Object "[" -ForegroundColor $sl.PromptSymbolColor
    Write-Prompt -Object $prompt -ForegroundColor $sl.PromptForegroundColor
    Write-Prompt -Object "]>" -ForegroundColor $sl.PromptSymbolColor
}

function Write-Segment
{
    param(
        $content,
        $foregroundColor
    )
    Write-Prompt -Object "[" -ForegroundColor $sl.PromptSymbolColor
    Write-Prompt -Object $content -ForegroundColor $foregroundColor
    Write-Prompt -Object "] " -ForegroundColor $sl.PromptSymbolColor
}

$sl = $global:ThemeSettings #local settings
