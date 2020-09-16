#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $adminsymbol = $sl.PromptSymbols.ElevatedSymbol
    $venvsymbol = $sl.PromptSymbols.VirtualEnvSymbol

    $lastColor = $sl.Colors.SessionInfoBackgroundColor
    $login = $sl.CurrentUser
    $computer = (Get-Culture).TextInfo.ToTitleCase([System.Environment]::MachineName.ToLower());
    if ($IsLinux) { $iconhex = 0xf17c }
    elseif ($IsMacOS) { $iconhex = 0xf302 }
    else { $iconhex = 0xe70f }

    ## Left Part
    $prompt = Write-Prompt -Object "╔═" -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += Write-Prompt -Object " $([char]::ConvertFromUtf32($iconhex))" -ForegroundColor $sl.Colors.StartForegroundColor
    $prompt += Write-Prompt -Object " $($sl.PromptSymbols.SegmentSubForwardSymbol)" -ForegroundColor $sl.Colors.UserForegroundColor
    $prompt += Write-Prompt -Object " $login@$computer " -ForegroundColor $sl.Colors.UserForegroundColor
    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.PromptSymbolColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $pathSymbol = if ($pwd.Path -eq $HOME) { $sl.PromptSymbols.PathHomeSymbol } else { $sl.PromptSymbols.PathSymbol }

    # Writes the drive portion
    $path = $pathSymbol + " " + (Get-ShortPath -dir $pwd) + " "
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.DriveForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $themeInfo.BackgroundColor
    }
    If ($with) {
        $sWith = " $($with.ToUpper())"
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentSubForwardSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        $prompt += Write-Prompt -Object $sWith -ForegroundColor $sl.Colors.WithForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor
    ###

    ## Right Part
    $rightElements = New-Object 'System.Collections.Generic.List[Tuple[string,ConsoleColor]]'

    $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentBackwardSymbol, $sl.Colors.StatsInfoBackgroundColor))
    # List of all right elements
    if (Test-VirtualEnv) {
        $rightElements.Add([System.Tuple]::Create(" $(Get-VirtualEnvName) $venvsymbol ", $sl.Colors.VirtualEnvForegroundColor))
        $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentSubBackwardSymbol, $sl.Colors.PromptForegroundColor))
    }
    if (Test-Administrator) {
        $rightElements.Add([System.Tuple]::Create(" $adminsymbol", $sl.Colors.AdminIconForegroundColor))
    }

    $battery = Get-BatteryInfo
    if ($battery) {
        $rightElements.Add([System.Tuple]::Create(" $battery ", $sl.Colors.PromptForegroundColor))
        $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentSubBackwardSymbol, $sl.Colors.PromptForegroundColor))
    }

    # Update the clock icon based on time
    [int]$hour = Get-Date -UFormat %I
    switch ($hour) {
        1 { $clockhex = 0xe382 }
        2 { $clockhex = 0xe383 }
        3 { $clockhex = 0xe384 }
        4 { $clockhex = 0xe385 }
        5 { $clockhex = 0xe386 }
        6 { $clockhex = 0xe387 }
        7 { $clockhex = 0xe388 }
        8 { $clockhex = 0xe389 }
        9 { $clockhex = 0xe38a }
        10 { $clockhex = 0xe38b }
        11 { $clockhex = 0xe38c }
        Default { $clockhex = 0xe381 }
    }
    $clocksymbol = [char]::ConvertFromUtf32($clockhex)
    $rightElements.Add([System.Tuple]::Create(" $(Get-Date -Format HH:mm:ss) $clocksymbol ", $sl.Colors.PromptForegroundColor))

    $lengthList = [Linq.Enumerable]::Select($rightElements, [Func[Tuple[string, ConsoleColor], int]] { $args[0].Item1.Length })
    $total = [Linq.Enumerable]::Sum($lengthList)
    # Transform into total length
    $prompt += Set-CursorForRightBlockWrite -textLength $total
    # The line head needs special care and is always drawn
    $prompt += Write-Prompt -Object $rightElements[0].Item1 -ForegroundColor $sl.Colors.StatsInfoBackgroundColor
    for ($i = 1; $i -lt $rightElements.Count; $i++) {
        $prompt += Write-Prompt -Object $rightElements[$i].Item1 -ForegroundColor $rightElements[$i].Item2 -BackgroundColor $sl.Colors.StatsInfoBackgroundColor
    }
    ###

    $prompt += Write-Prompt -Object "`r"
    $prompt += Set-Newline

    # Writes the postfixes to the prompt
    $indicatorColor = If ($lastCommandFailed) { $sl.Colors.CommandFailedIconForegroundColor } Else { $sl.Colors.PromptSymbolColor }
    $prompt += Write-Prompt -Object "╚═" -ForegroundColor $indicatorColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.SegmentSubForwardSymbol = [char]::ConvertFromUtf32(0xE0B1)
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2)
$sl.PromptSymbols.SegmentSubBackwardSymbol = [char]::ConvertFromUtf32(0xE0B3)
$sl.PromptSymbols.PathHomeSymbol = [char]::ConvertFromUtf32(0xf015)
$sl.PromptSymbols.PathSymbol = [char]::ConvertFromUtf32(0xf07c)
$sl.Colors.PromptBackgroundColor = [ConsoleColor]::DarkGray
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.StatsInfoBackgroundColor = [ConsoleColor]::Black
$sl.Colors.VirtualEnvBackgroundColor = [ConsoleColor]::DarkGray
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Blue
$sl.Colors.CommandFailedIconForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.SessionInfoForegroundColor = [ConsoleColor]::White
$sl.Colors.StartForegroundColor = [ConsoleColor]::Blue
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [ConsoleColor]::Magenta
$sl.Colors.UserForegroundColor = [ConsoleColor]::White
