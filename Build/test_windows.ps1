Install-Module Coveralls -MinimumVersion 1.0.25 -Scope CurrentUser -Force -ErrorAction Stop
Import-Module Coveralls -Force -ErrorAction Stop
$coverageSet = @('Helpers\PoshGit.ps1','Helpers\Prompt.ps1')
$res = Invoke-Pester -CodeCoverage $coverageSet -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru -EnableExit
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
if (!$ENV:CA_KEY) {
    $ENV:CA_KEY = "14mb4l0n1"
}
$coverageResult = Format-Coverage -PesterResults $res -CoverallsApiToken $ENV:CA_KEY -BranchName $ENV:APPVEYOR_REPO_BRANCH
Publish-Coverage -Coverage $coverageResult
