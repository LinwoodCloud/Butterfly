---
title: "Vinduer"
sidebar_position: 2
---

![Stable utgivelsesversjon](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Slipp versjon for nattlig](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

## Minimumskrav til systemer

* Windows 10 eller høyere.

## Binærfiler

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Stabil</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-setup-x86_64.exe">
        Oppsett
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-x86_64.zip">
        Portabel
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Nattlig</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-setup-x86_64.exe">
        Oppsett
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-x86_64.zip">
        Portabel
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Les mer om den nattlige versjonen av Butterfly [her](/nightly).

## Installer med winget

```powershell
winget install LinwoodCloud.Butterfly
```

For å oppgradere winget pakken, kjør

```powershell
winget upgrade LinwoodCloud.Butterfly
```

For å avinstallere winget pakken, kjør

```powershell
winget uninstall LinwoodCloud.Butterfly
```

### Nattlig versjon

```powershell
winget install LinwoodCloud.Butterfly.Nightly
```

For å oppgradere winget pakken, kjør

```powershell
winget upgrade LinwoodCloud.Butterfly.Nightly
```

For å avinstallere winget pakken, kjør

```powershell
winget uninstall LinwoodCloud.Butterfly.Nightly
```
