oh-my-posh
==========

[![Build status][build-status-badge]][build-status]
[![Coverage Status][coverage-status-badge]][coverage-status]
[![Gitter][gitter-badge]][gitter]
[![PS Gallery][psgallery-badge]][powershell-gallery]

## Table of Contents

* [About](#about)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configuration](#configuration)
* [Helper functions](#helper-functions)
* [Themes](#themes)

## About

A theme engine for Powershell in ConEmu inspired by the work done by Chris Benti on [PS-Config][chrisbenti-psconfig] and [Oh-My-ZSH][oh-my-zsh] on OSX and Linux (hence the name).

More information about why I made this can be found on my [blog].

![Theme][img-indications]

Features:

* Easy installation
* Awesome prompt themes for PowerShell in ConEmu
* Git status indications (powered by posh-git)
* Failed command indication
* Admin indication
* Current session indications (admin, failed command, user)
* Configurable
* Easily create your own theme
* Separate settings for oh-my-posh and posh-git
* Does not mess with the default Powershell console

## Prerequisites

You should use ConEmu to have a brilliant terminal experience on Windows. You can install it using [Chocolatey][chocolatey]:

```bash
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository][nerdfonts] containing them.
I use `Meslo LG M Regular for Powerline Nerd Font` in my ConEmu setup together with custom colors. You can find my theme [here][theme-gist].

## Installation

You need to use the the [PowerShell Gallery][powershell-gallery] to install oh-my-posh.

Install posh-git and oh-my-posh:

```bash
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

Enable engine in your PowerShell profile:

```bash
if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
notepad $PROFILE
```

Append following lines to your PowerShell profile:

```bash
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme paradox
```

Last command sets theme for the console. Check available themes list below.

## Configuration

List the current configuration:

```bash
$ThemeSettings
```

![Theme][img-themesettings]

You can tweak the settings by manipulating `$ThemeSettings`.
This example allows you to tweak the branch symbol using a unicode character:

````bash
$ThemeSettings.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
````

Also do not forget the Posh-Git settings itself (enable the stash indication for example):

```bash
$GitPromptSettings
```

Hide your `username@domain` when not in a virtual machine for the Agnoster, Fish, Honukai, Paradox and Sorin themes:

```bash
$DefaultUser = 'yourUsernameHere'
```

## Helper functions

`Set-Theme`:  set a theme from the Themes directory. If no match is found, it will not be changed. Autocomplete is available to list and complete available themes.

```bash
Set-Theme paradox
```

`Show-ThemeColors`: display the colors used by the theme

![Theme][img-themecolors]

`Show-Colors`: display colors configured in ConEmu

![Theme][img-showcolors]

## Themes

### Agnoster

![Agnoster Theme][img-theme-agnoster]

### Paradox

![Paradox Theme][img-theme-paradox]

### Sorin

![Sorin Theme][img-theme-sorin]

### Darkblood

![Darkblood Theme][img-theme-darkblood]

### Avit

![Avit Theme][img-theme-avit]

### Honukai

![Honukai Theme][img-theme-honukai]

### Fish

![Fish Theme][img-theme-fish]

## Creating your own theme

If you want to create a theme it can be done rather easily by adding a `mytheme.psm1` file in the folder indicated in `$ThemeSettings.MyThemesLocation` (the folder defaults to `~\Documents\WindowsPowerShell\PoshThemes`, feel free to change it).

The only required function is `Write-Theme`. You can use the following template to get started:

````bash
#requires -Version 2 -Modules posh-git

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # enter your prompt building logic here
}

$sl = $global:ThemeSettings #local settings
````

Feel free to use the public helper functions `Get-VCSStatus`, `Get-VcsInfo`, `Get-Drive`, `Get-ShortPath`, `Set-CursorForRightBlockWrite`, `Save-CursorPosition`, `Pop-CursorPosition`, `Set-CursorUp` or add your own logic completely.

To test the output in ConEmu, just switch to your theme:

```bash
Set-Theme mytheme
```

If you want to include your theme in oh-my-posh, send me a PR and I'll try to give feedback ASAP.

Happy theming!

### Based on work by

* [Chris Benti][chrisbenti-psconfig]
* [Keith Dahlby][keithdahlby-poshgit]



[build-status-badge]: https://img.shields.io/appveyor/ci/janjoris/oh-my-posh/master.svg?maxAge=2592000
[build-status]: https://ci.appveyor.com/project/JanJoris/oh-my-posh
[coverage-status-badge]: https://coveralls.io/repos/github/JanJoris/oh-my-posh/badge.svg
[coverage-status]: https://coveralls.io/github/JanJoris/oh-my-posh
[gitter-badge]: https://badges.gitter.im/oh-my-posh/Lobby.svg
[gitter]: https://gitter.im/oh-my-posh/general?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge
[psgallery-badge]: https://img.shields.io/badge/install-PS%20Gallery-blue.svg
[powershell-gallery]: https://www.powershellgallery.com/packages/oh-my-posh/
[chrisbenti-psconfig]: https://github.com/chrisbenti/PS-Config
[keithdahlby-poshgit]: https://github.com/dahlbyk/posh-git
[oh-my-zsh]: https://github.com/robbyrussell/oh-my-zsh
[blog]: https://herebedragons.io/shell-shock/
[chocolatey]: https://chocolatey.org/
[nerdfonts]: https://github.com/ryanoasis/nerd-fonts
[theme-gist]: https://gist.github.com/JanJoris/71c9f1361a562f337b855b75d7bbfd28
[img-indications]: https://herebedragons.io/images/indications.png
[img-themesettings]: https://herebedragons.io/images/themesettings.png
[img-themecolors]: https://herebedragons.io/images/themecolors.png
[img-showcolors]: https://herebedragons.io/images/showcolors.png
[img-theme-agnoster]: https://herebedragons.io/images/agnoster.png
[img-theme-paradox]: https://herebedragons.io/images/paradox.png
[img-theme-sorin]: https://herebedragons.io/images/sorin.png
[img-theme-darkblood]: https://herebedragons.io/images/darkblood.png
[img-theme-avit]: https://herebedragons.io/images/avit.png
[img-theme-honukai]: https://herebedragons.io/images/honukai.png
[img-theme-fish]: https://herebedragons.io/images/fish.png
