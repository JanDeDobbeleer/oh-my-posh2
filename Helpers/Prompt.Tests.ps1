$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test-IsVanillaWindow" {
    BeforeEach { Remove-Item Env:\PROMPT -ErrorAction SilentlyContinue
                 Remove-Item Env:\ConEmuANSI -ErrorAction SilentlyContinue }
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