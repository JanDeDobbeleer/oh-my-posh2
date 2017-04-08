oh-my-posh
==========

[![Build status](https://img.shields.io/appveyor/ci/janjoris/oh-my-posh/master.svg?maxAge=2592000)](https://ci.appveyor.com/project/JanJoris/oh-my-posh) [![Coverage Status](https://coveralls.io/repos/github/JanJoris/oh-my-posh/badge.svg)](https://coveralls.io/github/JanJoris/oh-my-posh) [![Gitter](https://badges.gitter.im/oh-my-posh/Lobby.svg)](https://gitter.im/oh-my-posh/general?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/oh-my-posh)

## Table of Contents

* [About](#about)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configuration](#configuration)
* [Helper functions](#helper)
* [Themes](#themes)

## About

A theme engine for Powershell in ConEmu inspired by the work done by Chris Benti on [PS-Config](https://github.com/chrisbenti/PS-Config). And [Oh-My-ZSH](https://github.com/robbyrussell/oh-my-zsh) on OSX and Linux (hence the name)
More information about why I made this can be found on my [blog](https://herebedragons.io/shell-shock/).

![Theme](https://herebedragons.io/img/indications.png)

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

You should use ConEmu to have a brilliant terminal experience on Windows. You can install it using [Chocolatey](https://chocolatey.org/):

```bash
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository](https://github.com/ryanoasis/nerd-fonts) containing them.
I use `Meslo LG M Regular for Powerline Nerd Font` in my ConEmu setup together with custom colors You can find my theme [here](https://gist.github.com/JanJoris/71c9f1361a562f337b855b75d7bbfd28).

## Installation

You need to use the the [PowerShell Gallery](https://www.powershellgallery.com/packages/oh-my-posh/) to install oh-my-posh.

Install posh-git and oh-my-posh:

```bash
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

## Configuration

List the current configuration:

```bash
$ThemeSettings
```

![Theme](http://janjoris.github.com/img/themesettings.png)

You can tweak the settings by manipulating `$ThemeSettings`.
This example allows you to tweak the branch symbol using a unicode character:

````bash
$ThemeSettings.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
````

Also do not forget the Posh-Git settings itself (enable the stash indication for example):

```bash
$GitPromptSettings
```

## Helper functions

`Set-Theme`:  set a theme from the Themes directory. If no match is found, it will not be changed. Autocomplete is available to list and complete available themes.

```bash
Set-Theme paradox
```

`Show-ThemeColors`: display the colors used by the theme

![Theme](http://janjoris.github.com/img/themecolors.png)

`Show-Colors`: display colors configured in ConEmu

![Theme](http://janjoris.github.com/img/showcolors.png)

## Themes

### Agnoster

![Theme](https://herebedragons.io/img/agnoster.png)

### Paradox

![Theme](https://herebedragons.io/img/paradox.png)

### Sorin

![Theme](https://herebedragons.io/img/sorin.png)

### Darkblood

![Theme](https://herebedragons.io/img/darkblood.png)

### Avit

![Theme](https://herebedragons.io/img/avit.png)

### Honukai

![Theme](https://herebedragons.io/img/honukai.png)

### Fish

![Theme](https://herebedragons.io/img/fish.png)

## Creating your own theme

If you want to create a theme it can be done rather easily by adding a `mytheme.psm1` file in the folder indicated in `$ThemeSettings.MyThemesLocation` (the folder defaults to `~\Documents\WindowsPowerShell\PoshThemes`, feel free to change it).
The only required function is Write-Theme, you can use the following template to get started:

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

* [Chris Benti](https://github.com/chrisbenti/PS-Config)
* [Keith Dahlby](https://github.com/dahlbyk/posh-git)
