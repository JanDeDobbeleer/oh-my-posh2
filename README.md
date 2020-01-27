# oh-my-posh

[![Build status][build-status-badge]][build-status]
[![Travis build status][travis-build-status-badge]][travis-build-status]
[![Coverage Status][coverage-status-badge]][coverage-status]
[![Gitter][gitter-badge]][gitter]
[![PS Gallery][psgallery-badge]][powershell-gallery]

## ❤ Support ❤

[![Patreon][patreon-badge]][patreon]
[![Liberapay][liberapay-badge]][liberapay]
[![Ko-Fi][kofi-badge]][kofi]

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

You can also install it using [Scoop][scoop] via the [extras bucket][scoop-extras]:

```bash
$ scoop search conemu
'extras' bucket:
  conemu (18.xx.xx)
$ scoop install conemu
```

The fonts I use are Powerline fonts, there is a great [repository][nerdfonts] containing them.
I use `Meslo LG M Regular for Powerline Nerd Font` in my ConEmu setup together with custom colors. You can find my theme [here][theme-gist].

In case you notice weird glyphs after installing a font of choice, make sure the glyphs are available (maybe they have a different location in the font, if so, adjust the correct `$ThemeSettings` icon). If it turns out the character you want is not supported, select a different font.

## Installation

You need to use the [PowerShell Gallery][powershell-gallery] to install oh-my-posh.

Install posh-git and oh-my-posh:

```powershell
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

Enable the prompt:

```powershell
# Start the default settings
Set-Prompt
# Alternatively set the desired theme:
Set-Theme Agnoster
```

In case you're running this on PS Core, make sure to also install version 2.0.0-beta1 of `PSReadLine`

    Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck

To enable the engine edit your PowerShell profile:

```bash
if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
notepad $PROFILE
```

Append the following lines to your PowerShell profile:

```bash
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox
```

The last command sets the theme for the console. Check the available themes list below.

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

### Robbyrussell

![Robbyrussell Theme][img-theme-robbyrussell]

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

Feel free to use the public helper functions `Get-VCSStatus`, `Get-VcsInfo`, `Get-FormattedRootLocation`, `Get-ShortPath`, `Set-CursorForRightBlockWrite`, `Set-CursorUp`, `Set-Newline` or add your own logic completely.

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
[travis-build-status-badge]: https://travis-ci.org/JanDeDobbeleer/oh-my-posh.svg?branch=master
[travis-build-status]: https://travis-ci.org/JanDeDobbeleer/oh-my-posh
[coverage-status-badge]: https://coveralls.io/repos/github/JanDeDobbeleer/oh-my-posh/badge.svg
[coverage-status]: https://coveralls.io/github/JanDeDobbeleer/oh-my-posh
[gitter-badge]: https://badges.gitter.im/oh-my-posh/Lobby.svg
[gitter]: https://gitter.im/oh-my-posh/general?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/oh-my-posh.svg
[powershell-gallery]: https://www.powershellgallery.com/packages/oh-my-posh/
[patreon-badge]: https://img.shields.io/badge/Support-Become%20a%20Patreon!-red.svg
[patreon]: https://www.patreon.com/jandedobbeleer
[liberapay-badge]: https://img.shields.io/badge/Liberapay-Donate-%23f6c915.svg
[liberapay]: https://liberapay.com/jandedobbeleer
[kofi-badge]: https://img.shields.io/badge/Ko--fi-Buy%20me%20a%20coffee!-%2346b798.svg
[kofi]: https://ko-fi.com/jandedobbeleer
[scoop]: https://scoop.sh/
[scoop-extras]: https://github.com/lukesampson/scoop/wiki/Buckets
[chrisbenti-psconfig]: https://github.com/chrisbenti/PS-Config
[keithdahlby-poshgit]: https://github.com/dahlbyk/posh-git
[oh-my-zsh]: https://github.com/robbyrussell/oh-my-zsh
[blog]: https://blog.itdepends.be/shell-shock/
[chocolatey]: https://chocolatey.org/
[nerdfonts]: https://github.com/ryanoasis/nerd-fonts
[theme-gist]: https://gist.github.com/JanDeDobbeleer/71c9f1361a562f337b855b75d7bbfd28
[img-indications]: img/indications.png
[img-themesettings]: img/themesettings.png
[img-themecolors]: img/themecolors.png
[img-showcolors]: img/showcolors.png
[img-theme-agnoster]: img/agnoster.png
[img-theme-paradox]: img/paradox.png
[img-theme-sorin]: img/sorin.png
[img-theme-darkblood]: img/darkblood.png
[img-theme-avit]: img/avit.png
[img-theme-honukai]: img/honukai.png
[img-theme-fish]: img/fish.png
[img-theme-robbyrussell]: img/robbyrussel.png
