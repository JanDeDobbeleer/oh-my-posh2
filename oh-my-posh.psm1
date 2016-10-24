#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\defaults.ps1"
. "$PSScriptRoot\Helpers\PoshGit.ps1"
. "$PSScriptRoot\Helpers\Prompt.ps1"

<#
        .SYNOPSIS
        Method called at each launch of Powershell

        .DESCRIPTION
        Sets up things needed in each console session, aside from prompt
#>
function Start-Up
{
    if(Test-Path -Path ~\.last)
    {
        (Get-Content -Path ~\.last) | Set-Location
        Remove-Item -Path ~\.last
    }

    # Makes git diff work
    $env:TERM = 'msys'
    Set-Prompt
}

<#
        .SYNOPSIS
        Generates the prompt before each line in the console
#>
function Set-Prompt
{
    Import-Module $sl.CurrentThemeLocation

    function global:prompt
    {
        $lastCommandFailed = $global:error.Count -gt $sl.ErrorCount
        $sl.ErrorCount = $global:error.Count

        #Start the vanilla posh-git when in a vanilla window, else: go nuts
        if(Test-IsVanillaWindow)
        {
            Write-Host -Object ($pwd.ProviderPath) -NoNewline
            Write-VcsStatus
            return '> '
        }

        Write-Theme -lastCommandFailed $lastCommandFailed
        return ' '
    }
}

function global:Write-WithPrompt()
{
    param(
        [string]
        $command
    )

    $lastCommandFailed = $global:error.Count -gt $sl.ErrorCount
    $sl.ErrorCount = $global:error.Count

    if(Test-IsVanillaWindow)
    {
        Write-ClassicPrompt -command $command 
        return
    }
    
    Write-Theme -lastCommandFailed $lastCommandFailed -with $command
    Write-Host ' ' -NoNewline
}

function Show-ThemeColors
{
    Write-Host -Object ''
    Write-ColorPreview -text 'GitDefaultColor                  ' -color $sl.Colors.GitDefaultColor
    Write-ColorPreview -text 'GitLocalChangesColor             ' -color $sl.Colors.GitLocalChangesColor
    Write-ColorPreview -text 'GitNoLocalChangesAndAheadColor   ' -color $sl.Colors.GitNoLocalChangesAndAheadColor
    Write-ColorPreview -text 'GitForegroundColor               ' -color $sl.Colors.GitForegroundColor
    Write-ColorPreview -text 'PromptForegroundColor            ' -color $sl.Colors.PromptForegroundColor
    Write-ColorPreview -text 'PromptBackgroundColor            ' -color $sl.Colors.PromptBackgroundColor
    Write-ColorPreview -text 'PromptSymbolColor                ' -color $sl.Colors.PromptSymbolColor
    Write-ColorPreview -text 'PromptHighlightColor             ' -color $sl.Colors.PromptHighlightColor
    Write-ColorPreview -text 'SessionInfoBackgroundColor       ' -color $sl.Colors.SessionInfoBackgroundColor
    Write-ColorPreview -text 'SessionInfoForegroundColor       ' -color $sl.Colors.SessionInfoForegroundColor
    Write-ColorPreview -text 'CommandFailedIconForegroundColor ' -color $sl.Colors.CommandFailedIconForegroundColor
    Write-ColorPreview -text 'AdminIconForegroundColor         ' -color $sl.Colors.AdminIconForegroundColor
    Write-ColorPreview -text 'WithBackgroundColor              ' -color $sl.Colors.WithBackgroundColor
    Write-ColorPreview -text 'WithForegroundColor              ' -color $sl.Colors.WithForegroundColor
    Write-Host -Object ''
}

function Write-ColorPreview
{
    param
    (
        [string]
        $text,
        [ConsoleColor]
        $color
    )

    Write-Host -Object $text -NoNewline
    Write-Host -Object '       ' -BackgroundColor $color
}

function Show-Colors
{
    for($i = 0; $i -lt 16; $i++)
    {
        $color = [ConsoleColor]$i
        Write-Host -Object $color -BackgroundColor $i
    }
}

function Set-Theme
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $name
    )

    if (Test-Path "$($sl.MyThemesLocation)\$($name).psm1")
    {
        $sl.CurrentThemeLocation = "$($sl.MyThemesLocation)\$($name).psm1"
    }
    elseif (Test-Path "$PSScriptRoot\Themes\$($name).psm1")
    {
        $sl.CurrentThemeLocation = "$PSScriptRoot\Themes\$($name).psm1"
    }
    else
    {
        Write-Host ''
        Write-Host "Theme $name not found. Available themes are:"
        Show-Themes
    }

    Set-Prompt
}

# Helper function to create argument completion results
function New-CompletionResult
{
    param(
        [Parameter(Mandatory)]
        [string]$CompletionText,
        [string]$ListItemText = $CompletionText,
        [System.Management.Automation.CompletionResultType]$CompletionResultType = [System.Management.Automation.CompletionResultType]::ParameterValue,
        [string]$ToolTip = $CompletionText
    )

    New-Object System.Management.Automation.CompletionResult $CompletionText, $ListItemText, $CompletionResultType, $ToolTip
}

function ThemeCompletion 
{
    param(
        $commandName, 
        $parameterName, 
        $wordToComplete, 
        $commandAst, 
        $fakeBoundParameter
    )
    $themes = @()
    Get-ChildItem -Path "$($ThemeSettings.MyThemesLocation)\*" -Include '*.psm1' -Exclude Tools.ps1 | ForEach-Object -Process { $themes += $_.BaseName }
    Get-ChildItem -Path "$PSScriptRoot\Themes\*" -Include '*.psm1' -Exclude Tools.ps1 | Sort-Object Name | ForEach-Object -Process { $themes += $_.BaseName }
    $themes | Where-Object {$_.ToLower().StartsWith($wordToComplete)} | ForEach-Object { New-CompletionResult -CompletionText $_  }
}

Register-ArgumentCompleter `
        -CommandName Set-Theme `
        -ParameterName name `
        -ScriptBlock $function:ThemeCompletion

$sl = $global:ThemeSettings #local settings
$sl.ErrorCount = $global:error.Count
Start-Up # Executes the Start-Up function, better encapsulation
