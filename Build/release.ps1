if ($ENV:APPVEYOR_REPO_BRANCH -eq 'master' -and [string]::IsNullOrWhiteSpace($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {
    Publish-Module -path . -NuGetApiKey $env:NG_KEY -Verbose
    #Create GitHub release
    Write-Host 'Starting GitHub release'
    $releaseData = @{
        tag_name         = $ENV:APPVEYOR_BUILD_VERSION
        target_commitish = 'master'
        name             = $ENV:APPVEYOR_BUILD_VERSION
        draft            = $false
        prerelease       = $false
    }
    $auth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($env:GH_KEY + ':x-oauth-basic'))
    $releaseParams = @{
        Uri         = 'https://api.github.com/repos/jandedobbeleer/oh-my-posh/releases'
        Method      = 'POST'
        Headers     = @{
            Authorization = $auth
        }
        ContentType = 'application/json'
        Body        = (ConvertTo-Json -InputObject $releaseData -Compress)
    }
    $result = Invoke-RestMethod @releaseParams
    $uploadUri = $result | Select-Object -ExpandProperty upload_url
    $uploadUri = $uploadUri -creplace '\{\?name,label\}'  #, '?name=oh-my-posh.zip'
    $uploadUri = $uploadUri + '?name=oh-my-posh.zip'
    $distFolder = Join-Path $env:APPVEYOR_BUILD_FOLDER dist
    mkdir $distFolder | Out-Null
    $excludedFiles = @(".*", "Build", "appveyor.yml", "TestsResults.xml", "dist")
    $distFiles = Get-ChildItem $env:APPVEYOR_BUILD_FOLDER -Exclude $excludedFiles
    $distFiles | Copy-Item -Destination $distFolder -Recurse
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($distFolder, "$HOME\Desktop\oh-my-posh.zip")
    $uploadParams = @{
        Uri         = $uploadUri
        Method      = 'POST'
        Headers     = @{
            Authorization = $auth
        }
        ContentType = 'application/zip'
        InFile      = "$HOME\Desktop\oh-my-posh.zip"
    }
    $result = Invoke-RestMethod @uploadParams
    Write-Host 'GitHub release completed'
}