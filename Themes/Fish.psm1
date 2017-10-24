#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # Create the right block first, set to 1 line up on the right
    Save-CursorPosition
    $date = Get-Date -UFormat %d-%m-%Y
    $timeStamp = Get-Date -UFormat %R 

    $leftText = "$($sl.PromptSymbols.SegmentBackwardSymbol) $date $($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $timeStamp "
    Set-CursorUp -lines 1
    Set-CursorForRightBlockWrite -textLength $leftText.Length

    Write-Prompt -Object "$($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $sl.Colors.PromptHighlightColor    
    Write-Prompt " $date $($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $timeStamp " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor 
    
    Pop-CursorPosition

    # Write the prompt
    Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    # Check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $computer = $env:computername
    $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
        
        if (Test-VirtualEnv) {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        Write-Prompt -Object $sl.PromptSymbols.SegmentSeparatorForwardSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor       
    }

    if ($with) {
        Write-Prompt -Object $sl.PromptSymbols.SegmentSeparatorForwardSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
        Write-Prompt -Object " $($with.ToUpper()) " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2)
$sl.PromptSymbols.SegmentSeparatorForwardSymbol = [char]::ConvertFromUtf32(0xE0B1)
$sl.PromptSymbols.SegmentSeparatorBackwardSymbol = [char]::ConvertFromUtf32(0xE0B3)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Magenta
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
