#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Themes\Tools.ps1"
. "$PSScriptRoot\defaults.ps1"

$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    Theme                            = 'Agnoster'
    GitBranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)
    FailedCommandSymbol              = [char]::ConvertFromUtf32(0x2A2F)
    TruncatedFolderSymbol            = '..'
    BeforeStashSymbol                = '{'
    AfterStashSymbol                 = '}'
    DelimSymbol                      = '|'
    LocalWorkingStatusSymbol         = '!'
    LocalStagedStatusSymbol          = '~'
    LocalDefaultStatusSymbol         = ''
    BranchUntrackedSymbol            = [char]::ConvertFromUtf32(0x2262)
    BranchIdenticalStatusToSymbol    = [char]::ConvertFromUtf32(0x2263)
    BranchAheadStatusSymbol          = [char]::ConvertFromUtf32(0x2191)
    BranchBehindStatusSymbol         = [char]::ConvertFromUtf32(0x2193)
    ElevatedSymbol                   = [char]::ConvertFromUtf32(0x26A1)
    GitDefaultColor                  = [ConsoleColor]::DarkCyan
    GitLocalChangesColor             = [ConsoleColor]::DarkGreen
    GitNoLocalChangesAndAheadColor   = [ConsoleColor]::DarkMagenta
    PromptForegroundColor            = [ConsoleColor]::Cyan
    PromptHighlightColor             = [ConsoleColor]::DarkBlue
    DriveForegroundColor             = [ConsoleColor]::DarkBlue
    PromptBackgroundColor            = [ConsoleColor]::DarkBlue
    PromptSymbolColor                = [ConsoleColor]::Red
    SessionInfoBackgroundColor       = [ConsoleColor]::Green
    CommandFailedIconForegroundColor = [ConsoleColor]::DarkYellow
    AdminIconForegroundColor         = [ConsoleColor]::DarkGreen
    ErrorCount                       = 0
}

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

    if(Get-Module -Name Posh-Git)
    {
        Start-SshAgent -Quiet
    }

    Set-Theme
}

<#
        .SYNOPSIS
        Generates the prompt before each line in the console
#>
function Set-Prompt
{
    Import-Module $PSScriptRoot\Themes\$($sl.Theme).psm1

    function global:prompt
    {
        $lastCommandFailed = $global:error.Count -gt $sl.ErrorCount
        $sl.ErrorCount = $global:error.Count

        #Start the vanilla posh-git when in a vanilla window, else: go nuts
        if(Test-IsVanillaWindow)
        {
            Write-Host -Object ($pwd.ProviderPath) -NoNewline
            Write-VcsStatus
            $global:LASTEXITCODE = !$lastCommandFailed
            return '> '
        }

        Write-Theme -lastCommandFailed $lastCommandFailed
        return ' '
    }
}

function Show-ThemeColors
{
    Write-Host -Object ''
    Write-ColorPreview -text 'GitDefaultColor                  ' -color $sl.GitDefaultColor
    Write-ColorPreview -text 'GitLocalChangesColor             ' -color $sl.GitLocalChangesColor
    Write-ColorPreview -text 'GitNoLocalChangesAndAheadColor   ' -color $sl.GitNoLocalChangesAndAheadColor
    Write-ColorPreview -text 'PromptForegroundColor            ' -color $sl.PromptForegroundColor
    Write-ColorPreview -text 'PromptBackgroundColor            ' -color $sl.PromptBackgroundColor
    Write-ColorPreview -text 'PromptSymbolColor                ' -color $sl.PromptSymbolColor
    Write-ColorPreview -text 'SessionInfoBackgroundColor       ' -color $sl.SessionInfoBackgroundColor
    Write-ColorPreview -text 'CommandFailedIconForegroundColor ' -color $sl.CommandFailedIconForegroundColor
    Write-ColorPreview -text 'AdminIconForegroundColor         ' -color $sl.AdminIconForegroundColor
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
    for($i = 1; $i -lt 16; $i++)
    {
        $color = [ConsoleColor]$i
        Write-Host -Object $color -BackgroundColor $i
    }
}

function Show-Themes
{
    Write-Host ''
    Write-Host 'Themes:'
    Write-Host ''
    Get-ChildItem -Path "$PSScriptRoot\Themes\*" -Include '*.ps1' -Exclude Tools.ps1 | Sort-Object Name | ForEach-Object -Process {write-Host "- $($_.BaseName)"} 
    Write-Host ''
    
}

function Set-Theme
{
    param(
        [string]$Theme
    )

    # if given a theme, check if the theme exists
    if ( $Theme )
    {
        if ( Test-Path "$PSScriptRoot\Themes\$($Theme).psm1" )
        {
            $sl.Theme = $Theme
        }
        else
        {
            throw "$Theme not found.  See currently installed themes with Show-Themes."
        }
    }
    else
    {
        # safety fallback for errors when using existing configured theme
        if ( !(Test-Path "$PSScriptRoot\Themes\$($sl.Theme).psm1") )
        {

            $sl.Theme = 'Agnoster'
        }
    }

    Set-Prompt
}

$sl = $global:ThemeSettings #local settings
$sl.ErrorCount = $global:error.Count
Start-Up # Executes the Start-Up function, better encapsulation
