#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $user = $s1.CurrentUser
    $prompt = Write-Prompt -Object "$user " -ForegroundColor $s1.Colors.PromptForegroundColor
    $prompt += Write-Prompt -Object ":: " -ForegroundColor $s1.Colors.AdminIconForegroundColor
    $prompt += Write-Prompt -Object "$(Get-FullPath -dir $pwd) " -ForegroundColor $s1.Colors.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $gitbranchpre = [char]::ConvertFromUtf32(0x003c)
        $gitbranchpost = [char]::ConvertFromUtf32(0x003e)

        $gitinfo = get-vcsinfo -status $status
        $prompt += Write-Prompt -Object "$gitbranchpre$($gitinfo.vcinfo)$gitbranchpost " -ForegroundColor $($gitinfo.backgroundcolor)
    }

    $prompt += Write-Prompt -Object $s1.PromptSymbols.PromptIndicator -ForegroundColor $s1.Colors.AdminIconForegroundColor
    $prompt += ' '
    $prompt
}

$s1 = $global:ThemeSettings
$s1.GitSymbols.BranchIdenticalStatusToSymbol = ""
$s1.GitSymbols.BranchSymbol = ""
$s1.GitSymbols.BranchUntrackedSymbol = "*"
$s1.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x00BB)

# Colors
$s1.Colors.PromptForegroundColor = [ConsoleColor]::White
$s1.Colors.AdminIconForegroundColor = [ConsoleColor]::Blue
$s1.Colors.DriveForegroundColor = [ConsoleColor]::Green
