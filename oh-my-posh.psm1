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
function Start-Up {
    if(Test-Path -Path ~\.last) {
        (Get-Content -Path ~\.last) | Set-Location
        Remove-Item -Path ~\.last
    }

    Set-Prompt
}

<#
        .SYNOPSIS
        Generates the prompt before each line in the console
#>
function Set-Prompt {
    Import-Module $sl.CurrentThemeLocation -Force

    [ScriptBlock]$Prompt = {
        $lastCommandFailed = $global:error.Count -gt $sl.ErrorCount
        $sl.ErrorCount = $global:error.Count

        #Start the vanilla posh-git when in a vanilla window, else: go nuts
        if(Test-IsVanillaWindow) {
            Write-Host -Object ($pwd.ProviderPath) -NoNewline
            Write-VcsStatus
        }

        Reset-CursorPosition
        Write-Theme -lastCommandFailed $lastCommandFailed
    }

    Set-Item -Path Function:prompt -Value $Prompt -Force
}

function global:Write-WithPrompt() {
    param(
        [string]
        $command
    )

    $lastCommandFailed = $global:error.Count -gt $sl.ErrorCount
    $sl.ErrorCount = $global:error.Count

    if(Test-IsVanillaWindow) {
        Write-ClassicPrompt -command $command
        return
    }

    Write-Theme -lastCommandFailed $lastCommandFailed -with $command
}

function Show-ThemeColors {
    ##############################
    #.SYNOPSIS
    # Show Current Theme Colors
    #
    #.DESCRIPTION
    # Good for checking if your current color mappings
    # work well with the theme.
    #
    ##############################
    Write-Host -Object ''
    $sl.Colors.Keys | Sort-Object | ForEach-Object { Write-ColorPreview -text ("{0,-35}" -f $_ ) -color $sl.Colors[$_] }
    Write-Host -Object ''
}

function Show-ThemeSymbols {
    ##############################
    #.SYNOPSIS
    # Show Current Theme Symbols
    #
    #.DESCRIPTION
    # Good for checking if your current font supports
    # all the symbols the theme uses.
    #
    ##############################
    Write-Host -Object "`n--PromptSymbols--`n"
    $sl.PromptSymbols.Keys | Sort-Object | ForEach-Object { Write-Host -Object ("{0,3} {1}" -f $sl.PromptSymbols[$_], $_) }
    Write-Host -Object ''
    Write-Host -Object "`n--GitSymbols--`n"
    $sl.GitSymbols.Keys | Sort-Object | ForEach-Object { Write-Host -Object ("{0,3} {1}" -f $sl.GitSymbols[$_], $_) }
    Write-Host -Object ''
}

function Write-ColorPreview {
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

function Show-Colors {
    for($i = 0; $i -lt 16; $i++) {
        $color = [ConsoleColor]$i
        Write-Host -Object $color -BackgroundColor $i
    }
}

function Set-Theme {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $name
    )

    if (Test-Path "$($sl.MyThemesLocation)\$($name).psm1") {
        $sl.CurrentThemeLocation = "$($sl.MyThemesLocation)\$($name).psm1"
    }
    elseif (Test-Path "$PSScriptRoot\Themes\$($name).psm1") {
        $sl.CurrentThemeLocation = "$PSScriptRoot\Themes\$($name).psm1"
    }
    elseif (Test-Path "$name") {
        $sl.CurrentThemeLocation = "$name"
    }
    else {
        Write-Host ''
        Write-Warning "Theme $name not found. Available themes are:"
        Get-Theme
    }

    Set-Prompt
}

# Helper function to create argument completion results
function New-CompletionResult {
    param(
        [Parameter(Mandatory)]
        [string]$CompletionText,
        [string]$ListItemText = $CompletionText,
        [System.Management.Automation.CompletionResultType]$CompletionResultType = [System.Management.Automation.CompletionResultType]::ParameterValue,
        [string]$ToolTip = $CompletionText
    )

    New-Object System.Management.Automation.CompletionResult $CompletionText, $ListItemText, $CompletionResultType, $ToolTip
}

function Get-Theme {
    ##############################
    #.SYNOPSIS
    # Get available theme(s)
    #.DESCRIPTION
    # Shows available themes, as well as their type and location
    # - Defaults (shipped with module)
    # - User (user defined themes)
    ##############################
    $themes = @()

    if (Test-Path "$($ThemeSettings.MyThemesLocation)\*") {
        Get-ChildItem -Path "$($ThemeSettings.MyThemesLocation)\*" -Include '*.psm1' -Exclude Tools.ps1 | ForEach-Object -Process {
            $themes += [PSCustomObject]@{
                Name = $_.BaseName
                Type = "User"
                Location = $_.FullName
            }
        }
    }

    Get-ChildItem -Path "$PSScriptRoot\Themes\*" -Include '*.psm1' -Exclude Tools.ps1 | Sort-Object Name | ForEach-Object -Process {
        $themes += [PSCustomObject]@{
                Name = $_.BaseName
                Type = "Defaults"
                Location = $_.FullName
        }
    }
    $themes
}

function ThemeCompletion {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )
    $themes = Get-Theme
    $themes |
        Where-Object { $_.Name.ToLower().StartsWith($wordToComplete.ToLower()); } |
        Select-Object -Unique -ExpandProperty Name |
        ForEach-Object { New-CompletionResult -CompletionText $_ }
}

Register-ArgumentCompleter `
        -CommandName Set-Theme `
        -ParameterName name `
        -ScriptBlock $function:ThemeCompletion

$sl = $global:ThemeSettings #local settings
$sl.ErrorCount = $global:error.Count
Start-Up # Executes the Start-Up function, better encapsulation
