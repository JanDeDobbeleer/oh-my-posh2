function Format-BranchName {
    param(
        [string]
        $branchName
    )

    if($spg.BranchNameLimit -gt 0 -and $branchName.Length -gt $spg.BranchNameLimit) {
        $branchName = ' {0}{1} ' -f $branchName.Substring(0, $spg.BranchNameLimit), $spg.TruncatedBranchSuffix
    }
    return " $branchName "
}

function Get-VCSStatus {
    if (Get-Command Get-GitStatus -errorAction SilentlyContinue) {
        $global:GitStatus = Get-GitStatus
        return $global:GitStatus
    }
    return $null
}

function Get-BranchSymbol($upstream) {
    # Add remote icon instead of branchsymbol if Enabled
    if (-not ($upstream) -or !$sl.Options.OriginSymbols) {
        return $sl.GitSymbols.BranchSymbol
    }
    $originUrl = Get-GitRemoteUrl $upstream
    if ($originUrl.Contains("github")) {
        return $sl.GitSymbols.OriginSymbols.Github
    }
    elseif ($originUrl.Contains("bitbucket")) {
        return $sl.GitSymbols.OriginSymbols.Bitbucket
    }
    elseif ($originUrl.Contains("gitlab")) {
        return $sl.GitSymbols.OriginSymbols.GitLab
    }
    return $sl.GitSymbols.BranchSymbol
}

function Get-GitRemoteUrl($upstream) {
    $origin = $upstream -replace "/.*"
    $originUrl = git remote get-url $origin
    return $originUrl
}


function Get-VcsInfo {
    param(
        [Object]
        $status,
        [Parameter(Mandatory=$false)][Int] $branchNameMaxLength
    )

    if ($status) {
        $branchStatusBackgroundColor = $sl.Colors.GitDefaultColor

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking)
        #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0))
        #hg/svn flags

        # There are local changes
        if($localChanges) {
            $branchStatusBackgroundColor = $sl.Colors.GitLocalChangesColor
        }
        # There are no local changes and the current branch is both ahead and behind
        elseif(($status.AheadBy -gt 0) -and ($status.BehindBy -gt 0)) {
            $branchStatusBackgroundColor = $sl.Colors.GitNoLocalChangesAndAheadAndBehindColor
        }
        # There are no local changes and the current branch is ahead only
        elseif ($status.AheadBy -gt 0) {
            $branchStatusBackgroundColor = $sl.Colors.GitNoLocalChangesAndAheadColor
        }
        # There are no local changes and the current branch is behind only
        elseif($status.BehindBy -gt 0) {
            $branchStatusBackgroundColor = $sl.Colors.GitNoLocalChangesAndBehindColor
        }

        $vcInfo = Get-BranchSymbol $status.Upstream
        $branchStatusSymbol = $null

        if (!$status.Upstream) {
            $branchStatusSymbol = $sl.GitSymbols.BranchUntrackedSymbol
        }
        elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
            # We are aligned with remote
            $branchStatusSymbol = $sl.GitSymbols.BranchIdenticalStatusToSymbol
        }
        elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
            # We are both behind and ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy) $($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.BehindBy -ge 1) {
            # We are behind remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.AheadBy -ge 1) {
            # We are ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy)"
        }
        else
        {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol = '?'
        }

        $branchName = $status.Branch
        if ($branchNameMaxLength -and $branchName.Length -gt $branchNameMaxLength) {
            $branchName = $branchName.Substring(0, $branchNameMaxLength);
        }

        $vcInfo = $vcInfo +  (Format-BranchName -branchName $branchName)

        if ($branchStatusSymbol) {
            $vcInfo = $vcInfo +  ('{0} ' -f $branchStatusSymbol)
        }

        if($spg.EnableFileStatus -and $status.HasIndex) {
            $vcInfo = $vcInfo +  $sl.GitSymbols.BeforeIndexSymbol

            if($spg.ShowStatusWhenZero -or $status.Index.Added) {
                $vcInfo = $vcInfo +  "$($spg.FileAddedText)$($status.Index.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Modified) {
                $vcInfo = $vcInfo +  "$($spg.FileModifiedText)$($status.Index.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Deleted) {
                $vcInfo = $vcInfo +  "$($spg.FileRemovedText)$($status.Index.Deleted.Count) "
            }

            if ($status.Index.Unmerged) {
                $vcInfo = $vcInfo +  "$($spg.FileConflictedText)$($status.Index.Unmerged.Count) "
            }

            if($status.HasWorking) {
                $vcInfo = $vcInfo +  "$($sl.GitSymbols.DelimSymbol) "
            }
        }

        if($spg.EnableFileStatus -and $status.HasWorking) {
            if (!$status.HasIndex) {
                $vcInfo = $vcInfo +  $sl.GitSymbols.BeforeWorkingSymbol
            }
            if($spg.showStatusWhenZero -or $status.Working.Added) {
                $vcInfo = $vcInfo +  "$($spg.FileAddedText)$($status.Working.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Modified) {
                $vcInfo = $vcInfo +  "$($spg.FileModifiedText)$($status.Working.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Deleted) {
                $vcInfo = $vcInfo +  "$($spg.FileRemovedText)$($status.Working.Deleted.Count) "
            }
            if ($status.Working.Unmerged) {
                $vcInfo = $vcInfo +  "$($spg.FileConflictedText)$($status.Working.Unmerged.Count) "
            }
        }

        if ($status.HasWorking) {
            # We have un-staged files in the working tree
            $localStatusSymbol = $sl.GitSymbols.LocalWorkingStatusSymbol
        }
        elseif ($status.HasIndex) {
            # We have staged but uncommited files
            $localStatusSymbol = $sl.GitSymbols.LocalStagedStatusSymbol
        }
        else {
            # No uncommited changes
            $localStatusSymbol = $sl.GitSymbols.LocalDefaultStatusSymbol
        }

        if ($localStatusSymbol) {
            $vcInfo = $vcInfo +  ('{0} ' -f $localStatusSymbol)
        }

        if ($status.StashCount -gt 0) {
            $vcInfo = $vcInfo +  "$($sl.GitSymbols.BeforeStashSymbol)$($status.StashCount)$($sl.GitSymbols.AfterStashSymbol) "
        }

        return New-Object PSObject -Property @{
            BackgroundColor = $branchStatusBackgroundColor
            VcInfo          = $vcInfo.Trim()
        }
    }
}

$spg = $global:GitPromptSettings #Posh-Git settings
$sl = $global:ThemeSettings #local settings
