#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # Writes the drive portion
    $prompt += Write-Prompt -Object "$(Get-FullPath -dir $pwd) " -ForegroundColor $sl.Colors.DriveForegroundColor

    # Git Status
    $status = Get-VCSStatus
    if ($status) {
        $prompt += Write-Prompt -Object ":: "
        $prompt += Write-Prompt -Object "git(" -ForegroundColor $sl.Colors.PromptHighlightColor
        $prompt += Write-Prompt -Object "$($status.Branch)" -ForegroundColor $sl.Colors.GitDefaultColor
        $prompt += Write-Prompt -Object ")" -ForegroundColor $sl.Colors.PromptHighlightColor
        if ($status.Working.Length -gt 0) {
            $prompt += Write-Prompt -Object (" " + $sl.PromptSymbols.GitDirtyIndicator) -ForegroundColor $sl.Colors.PromptSymbolColor
        }
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }


    # timestamp and env
    $sTime = "$(Get-Date -Format hh:mm) "
    $sTime += "$(Get-Date -UFormat %p)"
    $env = ""

    if (test-VirtualEnv){
        $env = "[ $(Get-VirtualEnvName) ] "
    }

    $rightPrompt = "$env$sTime"
    $prompt += Set-CursorForRightBlockWrite -textLength $rightPrompt.Length
    $prompt += Write-Prompt -Object $env -ForegroundColor $sl.colors.WithForegroundColor
    $prompt += Write-Prompt -Object $sTime -ForegroundColor $sl.colors.PromptHighlightColor

    $prompt += Set-Newline
    
    $user=$sl.CurrentUser
    $prompt+= Write-Prompt -Object ('@'+$user) -ForegroundColor $sl.Colors.WithForegroundColor
    $prompt+= Write-Prompt -Object " "

    #check the last command state and indicate if failed and change the colors of the arrows
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator+' ')  -ForegroundColor  $sl.Colors.WithForegroundColor   
    }else{
        $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator+' ') -ForegroundColor  $sl.Colors.PromptSymbolColor  
    }
    
    $prompt
}


$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x279C)
$sl.PromptSymbols.HomeSymbol = '~'
$sl.PromptSymbols.GitDirtyIndicator =[char]::ConvertFromUtf32(10007)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Blue
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow
