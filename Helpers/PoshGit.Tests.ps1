$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    GitSymbols                       = @{
        BranchSymbol                  = 'branch'
        OriginSymbols                    = @{
            Enabled                         = $false
            Github                    = [char]::ConvertFromUtf32(0xF09B)
            Bitbucket                 = [char]::ConvertFromUtf32(0xF171)
            GitLab                    = [char]::ConvertFromUtf32(0xF296)
        }
    }
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


Describe "Test-GetBranchSymbol" {
    Context "Is disabled" {
        BeforeAll {
            $global:ThemeSettings.GitSymbols.OriginSymbols.Enabled = $false
        }
        It "Has Enabled set to False" {
            Mock Get-GitRemoteUrl { return 'github.com/test.git' }
            $symbol = Get-BranchSymbol 'origin/master'
            $symbol | Should Be $themeSettings.GitSymbols.BranchSymbol
        }
        It "Has has no upstream" {
            $symbol = Get-BranchSymbol
            $symbol | Should Be $themeSettings.GitSymbols.BranchSymbol
        }
    }
    Context "Is enabled" {
        BeforeAll {
            $global:ThemeSettings.GitSymbols.OriginSymbols.Enabled = $true
        }
        It "Uses GitHub" {
            Mock Get-GitRemoteUrl { return 'github.com/test.git' }
            $symbol = Get-BranchSymbol 'origin/master'
            $symbol | Should Be $themeSettings.GitSymbols.OriginSymbols.Github
        }
        It "Uses GitLab" {
            Mock Get-GitRemoteUrl { return 'gitlab.com/test.git' }
            $symbol = Get-BranchSymbol 'origin/master'
            $symbol | Should Be $themeSettings.GitSymbols.OriginSymbols.GitLab
        }
        It "Uses BitBucket" {
            Mock Get-GitRemoteUrl { return 'bitbucket.com/test.git' }
            $symbol = Get-BranchSymbol 'origin/master'
            $symbol | Should Be $themeSettings.GitSymbols.OriginSymbols.Bitbucket
        }
        It "Uses something else" {
            Mock Get-GitRemoteUrl { return 'example.com/test.git' }
            $symbol = Get-BranchSymbol 'origin/master'
            $symbol | Should Be $themeSettings.GitSymbols.BranchSymbol
        }
        It "Has no remote" {
            $symbol = Get-BranchSymbol
            $symbol | Should Be $themeSettings.GitSymbols.BranchSymbol
        }
    }
}
