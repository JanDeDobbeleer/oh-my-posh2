$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    CurrentThemeLocation             = "$PSScriptRoot\Themes\Agnoster.psm1"
    MyThemesLocation                 = '~\Documents\WindowsPowerShell\PoshThemes'
    ErrorCount                       = 0
    PromptSymbols                    = @{
        StartSymbol                      = ' '        
        TruncatedFolderSymbol            = '..'
        PromptIndicator                  = '>' 
        FailedCommandSymbol              = 'x'        
        ElevatedSymbol                   = '!'
        SegmentForwardSymbol             = '>'
        SegmentBackwardSymbol            = '<'
        SegmentSeparatorForwardSymbol    = '>'
        SegmentSeparatorBackwardSymbol   = '<'
        PathSeparator                    = '\'
    }
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test-IsVanillaWindow" {
    BeforeEach { Remove-Item Env:\PROMPT -ErrorAction SilentlyContinue
                 Remove-Item Env:\ConEmuANSI -ErrorAction SilentlyContinue
                 Remove-Item Env:\TERM_PROGRAM -ErrorAction SilentlyContinue }
    Context "Running in a non-vanilla window" {
        It "runs in ConEmu and outputs 'false'" {
        $env:PROMPT = $false
        $env:ConEmuANSI = $true
        Test-IsVanillaWindow | Should Be $false
        }
        It "runs in cmder and outputs 'false'" {
            $env:ConEmuANSI = $false
            $env:PROMPT = $true
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in ConEmu and outputs 'false'" {
            $env:ConEmuANSI = $true
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in cmder and outputs 'false'" {
            $env:PROMPT = $true
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in cmder and conemu and outputs 'false'" {
            $env:PROMPT = $true
            $env:ConEmuANSI = $true
            Test-IsVanillaWindow | Should Be $false
        }
        It "runs in Hyper.js and outputs 'false'" {
            $env:TERM_PROGRAM = "Hyper"
            Test-IsVanillaWindow | Should Be $false
        }
    }
    Context "Running in a vanilla window" {
        It "runs in a vanilla window and outputs 'true'" {
           Test-IsVanillaWindow | Should Be $true
        }
    }
}

Describe "Get-Home" {
    It "returns $HOME" {
           Get-Home | Should Be $HOME
        }
}

Describe "Get-Provider" {
    It "uses the provider 'AwesomeSauce'" {
           Mock Get-Item { return @{PSProvider = @{Name = 'AwesomeSauce'}} }
           Get-Provider $pwd | Should Be 'AwesomeSauce'
        }
}

Describe "Get-Drive" {
    Context "Running in the FileSystem" {
        BeforeAll { Mock Get-Provider { return 'FileSystem'} }
        It "is in the $HOME folder" {
           Mock Get-Home {return 'C:\Users\Jan'}
           $path = @{Drive = @{Name = 'C:'}; Path = 'C:\Users\Jan'}
           Get-Drive $path | Should Be '~'
        }
        It "is somewhere in the $HOME folder" {
           Mock Get-Home {return 'C:\Users\Jan'}
           $path = @{Drive = @{Name = 'C:'}; Path = 'C:\Users\Jan\Git\Somewhere'}
           Get-Drive $path | Should Be '~'
        }
        It "is in 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello' with provider X:" {
           $path = @{Drive = @{Name = 'X:'}; Path = 'Microsoft.PowerShell.Core\FileSystem::\\Test\Hello'}
           Get-Drive $path | Should Be "Test$($ThemeSettings.PromptSymbols.PathSeparator)Hello$($ThemeSettings.PromptSymbols.PathSeparator)"
        }
        It "is in C:" {
           $path = @{Drive = @{Name = 'C:'}; Path = 'C:\Documents'}
           Get-Drive $path | Should Be 'C:'
        }
        It "is has no drive" {
           $path = @{Path = 'J:\Test\Folder\Somewhere'}
           Get-Drive $path | Should Be 'J:'
        }
        It "is has no valid path" {
           $path = @{Path = 'J\Test\Folder\Somewhere'}
           Get-Drive $path | Should Be 'J:'
        }
    }
    Context "Running outside of the FileSystem" {
        BeforeAll { Mock Get-Provider { return 'SomewhereElse'} }
        It "running outside of the Filesystem in L:" {
           $path = @{Drive = @{Name = 'L:'}; Path = 'L:\Documents'}
           Get-Drive $path | Should Be 'L:'
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
        It "same username and inside VirtualEnv same default user gives 'true'" {
            Mock Test-VirtualEnv { return $true }
            $user = 'name'
            Test-NotDefaultUser($user) | Should Be $true
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