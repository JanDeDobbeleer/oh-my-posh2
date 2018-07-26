# Oh-My-Posh default settings
$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    CurrentThemeLocation             = "$PSScriptRoot\Themes\Agnoster.psm1"
    MyThemesLocation                 = (Join-Path (Split-Path -Parent $PROFILE) "PoshThemes")
    ErrorCount                       = 0
    GitSymbols                       = @{
        BranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)
        BeforeStashSymbol             = '{'
        BeforeIndexSymbol             = ''
        BeforeWorkingSymbol           = ''
        AfterStashSymbol              = '}'
        DelimSymbol                   = '|'
        LocalWorkingStatusSymbol      = '!'
        LocalStagedStatusSymbol       = '~'
        LocalDefaultStatusSymbol      = ''
        BranchUntrackedSymbol         = [char]::ConvertFromUtf32(0x2262)
        BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2263)
        BranchAheadStatusSymbol       = [char]::ConvertFromUtf32(0x2191)
        BranchBehindStatusSymbol      = [char]::ConvertFromUtf32(0x2193)
        OriginSymbols                    = @{
            Enabled                         = $false
            Github                    = [char]::ConvertFromUtf32(0xF09B)
            Bitbucket                 = [char]::ConvertFromUtf32(0xF171)
            GitLab                    = [char]::ConvertFromUtf32(0xF296)
        }
    }
    PromptSymbols                    = @{
        StartSymbol                      = ' '
        TruncatedFolderSymbol            = '..'
        PromptIndicator                  = [char]::ConvertFromUtf32(0x25B6)
        FailedCommandSymbol              = [char]::ConvertFromUtf32(0x2A2F)
        ElevatedSymbol                   = [char]::ConvertFromUtf32(0x26A1)
        SegmentForwardSymbol             = [char]::ConvertFromUtf32(0xE0B0)
        SegmentBackwardSymbol            = [char]::ConvertFromUtf32(0x26A1)
        SegmentSeparatorForwardSymbol    = [char]::ConvertFromUtf32(0x26A1)
        SegmentSeparatorBackwardSymbol   = [char]::ConvertFromUtf32(0x26A1)
        PathSeparator                    = [System.IO.Path]::DirectorySeparatorChar
        VirtualEnvSymbol                 = [char]::ConvertFromUtf32(0xE606)
    }
    Colors               = @{
        GitDefaultColor                  = [ConsoleColor]::DarkGreen
        GitLocalChangesColor             = [ConsoleColor]::DarkYellow
        GitNoLocalChangesAndAheadColor   = [ConsoleColor]::DarkMagenta
        PromptForegroundColor            = [ConsoleColor]::White
        PromptHighlightColor             = [ConsoleColor]::DarkBlue
        DriveForegroundColor             = [ConsoleColor]::DarkBlue
        PromptBackgroundColor            = [ConsoleColor]::DarkBlue
        PromptSymbolColor                = [ConsoleColor]::White
        SessionInfoBackgroundColor       = [ConsoleColor]::Black
        SessionInfoForegroundColor       = [ConsoleColor]::White
        CommandFailedIconForegroundColor = [ConsoleColor]::DarkRed
        AdminIconForegroundColor         = [ConsoleColor]::DarkYellow
        WithBackgroundColor              = [ConsoleColor]::DarkRed
        WithForegroundColor              = [ConsoleColor]::White
        GitForegroundColor               = [ConsoleColor]::Black
        VirtualEnvForegroundColor        = [ConsoleColor]::White
        VirtualEnvBackgroundColor        = [ConsoleColor]::Red
    }
}

# PSColor default settings
$global:PSColor = @{
    File    = @{
        Default    = @{ Color = 'White' }
        Directory  = @{ Color = 'DarkBlue' }
        Hidden     = @{ Color = 'Gray'; Pattern = '^\.' }
        Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = 'White'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = 'DarkGreen'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
    }
    Service = @{
        Default = @{ Color = 'White' }
        Running = @{ Color = 'DarkGreen' }
        Stopped = @{ Color = 'DarkYellow' }
    }
    Match   = @{
        Default    = @{ Color = 'White' }
        Path       = @{ Color = 'Cyan' }
        LineNumber = @{ Color = 'DarkGreen' }
        Line       = @{ Color = 'White' }
    }
}
