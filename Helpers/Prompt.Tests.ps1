$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test-IsVanillaWindow" {
    BeforeEach { Remove-Item Env:\PROMPT -ErrorAction SilentlyContinue
                 Remove-Item Env:\ConEmuANSI -ErrorAction SilentlyContinue }
    # $env:PROMPT -or $env:ConEmuANSI
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
    It "runs in a vanilla window and outputs 'true'" {
        Test-IsVanillaWindow | Should Be $true
    }
}