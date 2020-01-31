$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    CurrentThemeLocation = "$PSScriptRoot\Themes\Agnoster.psm1"
    MyThemesLocation     = '~\Documents\WindowsPowerShell\PoshThemes'
    ErrorCount           = 0
    PromptSymbols        = @{
        StartSymbol                    = ' '
        TruncatedFolderSymbol          = '..'
        PromptIndicator                = '>'
        FailedCommandSymbol            = 'x'
        ElevatedSymbol                 = '!'
        SegmentForwardSymbol           = '>'
        SegmentBackwardSymbol          = '<'
        SegmentSeparatorForwardSymbol  = '>'
        SegmentSeparatorBackwardSymbol = '<'
        PathSeparator                  = '\'
        HomeSymbol                     = '*'
        RootSymbol                     = '#'
        UNCSymbol                      = '§'
    }
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function New-MockPath {
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProviderName,
        [Parameter(Mandatory = $false)]
        [System.String]
        $DriveName
    )
    
    $provider = New-MockObject -Type System.Management.Automation.ProviderInfo 
    $path = New-MockObject -Type System.Management.Automation.PathInfo 
    $provider | Add-Member -Type NoteProperty -Name 'Name' -Value $ProviderName -Force
    $path | Add-Member -Type NoteProperty -Name 'Path' -Value $Location -Force
    $path | Add-Member -Type NoteProperty -Name 'Provider' -Value $provider -Force
    if ($null -ne $DriveName) {
        $driveInfo = New-MockObject -Type System.Management.Automation.PSDriveInfo
        $driveInfo | Add-Member -Type NoteProperty -Name 'Name' -Value $DriveName -Force
        $path | Add-Member -Type NoteProperty -Name 'Drive' -Value $driveInfo -Force
    }
    return $path
}

Describe "Test-IsVanillaWindow" {
    BeforeEach { Remove-Item Env:\ConEmuANSI -ErrorAction SilentlyContinue
        Remove-Item Env:\PROMPT -ErrorAction SilentlyContinue
        Remove-Item Env:\TERM_PROGRAM -ErrorAction SilentlyContinue }
    Context "Running in a non-vanilla window" {
        It "runs in ConEmu and outputs 'false'" {
            $env:ConEmuANSI = "ON"
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in ConEmu and outputs 'false'" {
            $env:ConEmuANSI = "ON"
            Mock Test-AnsiTerminal { return $true }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in an ANSI supported terminal and outputs 'false'" {
            $env:ConEmuANSI = $false
            Mock Test-AnsiTerminal { return $true }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in ConEmu and outputs 'false'" {
            $env:ConEmuANSI = $true
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in cmder and outputs 'false'" {
            $env:PROMPT = $true
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in cmder and conemu and outputs 'false'" {
            $env:PROMPT = $true
            $env:ConEmuANSI = $true
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in Hyper.js and outputs 'false'" {
            $env:TERM_PROGRAM = "Hyper"
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in vscode and outputs 'false'" {
            $env:TERM_PROGRAM = "vscode"
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $false
        }
    }
    Context "Running in a vanilla window" {
        It "runs in a vanilla window and outputs 'true'" {
            Mock Test-AnsiTerminal { return $false }
            Test-IsVanillaWindow | Should Be $true
        }
    }
}

Describe "Get-Home" {
    It "returns $($HOME.TrimEnd('/','\'))" {
        Get-Home | Should Be $HOME.TrimEnd('/', '\')
    }
}

Describe "Get-Provider" {
    It "uses the provider 'AwesomeSauce'" {
        $expected = 'AwesomeSauce'
        $path = New-MockPath -Location 'C:\Users\Jan\Test' -ProviderName $expected
        Get-Provider $path | Should Be $expected
    }
}

Describe "Get-FormattedRootLocation" {
    Context "Running in the FileSystem" {
        BeforeAll { 
            Mock Get-Home { return 'C:\Users\Jan' } 
            Mock Test-Windows { return $true }
        }
        It "is in the $HOME folder" {
            $path = New-MockPath -Location 'C:\Users\Jan' -ProviderName 'FileSystem' -DriveName 'C'
            Get-FormattedRootLocation $path | Should Be $ThemeSettings.PromptSymbols.HomeSymbol
        }
        It "is somewhere in the $HOME folder" {
            $path = New-MockPath -Location 'C:\Users\Jan\Git\Somewhere' -ProviderName 'FileSystem' -DriveName 'C'
            Get-FormattedRootLocation $path | Should Be $ThemeSettings.PromptSymbols.HomeSymbol
        }
        It "is in 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello' with Drive X:" {
            $path = New-MockPath -Location 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello' -ProviderName 'FileSystem' -DriveName 'X'
            Get-FormattedRootLocation $path | Should Be $ThemeSettings.PromptSymbols.UNCSymbol
        }
        It "is in C:" {
            $path = New-MockPath -Location 'C:\Documents' -ProviderName 'FileSystem' -DriveName 'C'
            Get-FormattedRootLocation $path | Should Be ''
        }
        It "is has no drive" {
            $path = New-MockPath -Location 'J:\Test\Folder\Somewhere' -ProviderName 'FileSystem' -DriveName 'J'
            Get-FormattedRootLocation $path | Should Be ''
        }
        It "is has no valid path" {
            if (Test-PsCore) {
                $true | Should Be $true
            }
            else {
                $path = New-MockPath -Location 'J\Test\Folder\Somewhere' -ProviderName 'FileSystem' -DriveName 'J'
                Get-FormattedRootLocation $path | Should Be 'J:'
            }
        }
    }
    Context "Running outside of the FileSystem" {
        It "running outside of the Filesystem in L:" {
            $path = New-MockPath -Location 'L:\Documents\Somewhere' -ProviderName 'SomewhereElse' -DriveName 'L'
            Get-FormattedRootLocation $path | Should Be 'L'
        }
    }
}

Describe "Get-FullPath" {
    Context "Running in the FileSystem" {
        BeforeAll { Mock Get-Home { return 'C:\Users\Jan' } }
        It "is in the $HOME folder" {
            $path = New-MockPath -Location 'C:\Users\Jan' -ProviderName 'FileSystem' -DriveName 'C'
            Get-FullPath $path | Should Be $ThemeSettings.PromptSymbols.HomeSymbol
        }
        It "is somewhere in the $HOME folder" {
            $path = New-MockPath -Location 'C:\Users\Jan\Git\Somewhere' -ProviderName 'FileSystem' -DriveName 'C'
            Get-FullPath $path | Should Be "$($ThemeSettings.PromptSymbols.HomeSymbol)\Git\Somewhere"
        }
    }
}

Describe "Get-ShortPath" {
    if (Test-Windows) {
        Context "Running in the FileSystem on Windows" {
            BeforeAll {
                Mock Get-Home { return 'C:\Users\Jan' }
                Mock Get-OSPathSeparator { return '\' }
            }
            It "is in a root folder" {
                $path = New-MockPath -Location 'C:\Users\' -ProviderName 'FileSystem' -DriveName 'C'
                Get-ShortPath $path | Should Be "C:$($ThemeSettings.PromptSymbols.PathSeparator)Users"
            }
            It "is outside the $HOME folder" {
                $path = New-MockPath -Location 'C:\Tools\Something' -ProviderName 'FileSystem' -DriveName 'C'
                Get-ShortPath $path | Should Be "C:$($ThemeSettings.PromptSymbols.PathSeparator)$($ThemeSettings.PromptSymbols.TruncatedFolderSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)Something"
            }
            It "is in the $HOME folder" {
                $path = New-MockPath -Location 'C:\Users\Jan\' -ProviderName 'FileSystem' -DriveName 'C'
                Get-ShortPath $path | Should Be $ThemeSettings.PromptSymbols.HomeSymbol
            }
            It "is somewhere in the $HOME folder" {
                $path = New-MockPath -Location 'C:\Users\Jan\Git\Somewhere' -ProviderName 'FileSystem' -DriveName 'C'
                Get-ShortPath $path | Should Be "$($ThemeSettings.PromptSymbols.HomeSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)$($ThemeSettings.PromptSymbols.TruncatedFolderSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)Somewhere"
            }
            It "is in 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello'" {
                $path = New-MockPath -Location 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello' -ProviderName 'FileSystem' -DriveName 'Microsoft.PowerShell.Core'
                Get-ShortPath $path | Should Be "$($ThemeSettings.PromptSymbols.UNCSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)$($ThemeSettings.PromptSymbols.TruncatedFolderSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)Hello"
            }
        }
    }
    if (-Not (Test-Windows)) {
        Context "Running on the filesystem in UNIX" {
            BeforeAll { 
                Mock Get-Home { return '/Users/Jan' }
                Mock Get-OSPathSeparator { return '/' }
            }
            It "is outside the $HOME folder" {
                $path = New-MockPath -Location 'C:/Tools/Something' -ProviderName 'FileSystem' -DriveName 'C'
                Get-ShortPath $path | Should Be "C:$($ThemeSettings.PromptSymbols.PathSeparator)$($ThemeSettings.PromptSymbols.TruncatedFolderSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)Something"
            }
            It "is in a root folder" {
                $path = New-MockPath -Location '/Users/' -ProviderName 'FileSystem' -DriveName '/'
                Get-ShortPath $path | Should Be 'Users'
            }
            It "is in the $HOME folder" {
                $path = New-MockPath -Location '/Users/Jan/' -ProviderName 'FileSystem' -DriveName '/'
                Get-ShortPath $path | Should Be $ThemeSettings.PromptSymbols.HomeSymbol
            }
            It "is somewhere in the $HOME folder" {
                $path = New-MockPath -Location '/Users/Jan/Git/Somewhere' -ProviderName 'FileSystem' -DriveName '/'
                Get-ShortPath $path | Should Be "$($ThemeSettings.PromptSymbols.HomeSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)$($ThemeSettings.PromptSymbols.TruncatedFolderSymbol)$($ThemeSettings.PromptSymbols.PathSeparator)Somewhere"
            }
        }
    }
}

Describe "Test-NotDefaultUser" {
    Context "With default user set" {
        BeforeAll { $DefaultUser = 'name' }
        It "same username gives 'false'" {
            $user = 'name'
            Test-NotDefaultUser($user) | Should Be $false
        }
        It "different username gives 'false'" {
            $user = 'differentName'
            Test-NotDefaultUser($user) | Should Be $true
        }
        It "same username and outside VirtualEnv gives 'false'" {
            Mock Test-VirtualEnv { return $false }
            $user = 'name'
            Test-NotDefaultUser($user) | Should Be $false
        }
        It "same username and inside VirtualEnv same default user gives 'false'" {
            Mock Test-VirtualEnv { return $true }
            $user = 'name'
            Test-NotDefaultUser($user) | Should Be $false
        }
        It "different username and inside VirtualEnv same default user gives 'true'" {
            Mock Test-VirtualEnv { return $true }
            $user = 'differentName'
            Test-NotDefaultUser($user) | Should Be $true
        }
    }
    Context "With no default user set" {
        BeforeAll { $DefaultUser = $null }
        It "no username gives 'true'" {
            Test-NotDefaultUser | Should Be $true
        }
        It "different username gives 'true'" {
            $user = 'differentName'
            Test-NotDefaultUser($user) | Should Be $true
        }
        It "different username and outside VirtualEnv gives 'true'" {
            Mock Test-VirtualEnv { return $false }
            $user = 'differentName'
            Test-NotDefaultUser($user) | Should Be $true
        }
        It "no username and inside VirtualEnv gives 'true'" {
            Mock Test-VirtualEnv { return $true }
            Test-NotDefaultUser($user) | Should Be $true
        }
    }
}
