---
title: "Vinduer"
sidebar_position: 2
---

![Stabil version](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Nightly release version](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

## Mindstekrav til systemet

* Windows 10 eller højere.

## Binære

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Stabil</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-setup-x86_64.exe">
        Opsætning
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-x86_64.zip">
        Bærbar
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Natligt</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-setup-x86_64.exe">
        Opsætning
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-x86_64.zip">
        Bærbar
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Læs mere om natteversionen af Butterfly [her](/nightly).

## Installér vha. winget

```powershell
winget install LinwoodCloud.Butterfly
```

For at opgradere winget-pakken, køre:

```powershell
winget upgrade LinwoodCloud.Butterfly
```

For at afinstallere winget-pakken, kør

```powershell
winget uninstall LinwoodCloud.Butterfly
```

### Nightly version

```powershell
winget install LinwoodCloud.Butterfly.Nightly
```

For at opgradere winget-pakken, køre:

```powershell
winget upgrade LinwoodCloud.Butterfly.Nightly
```

For at afinstallere winget-pakken, kør

```powershell
winget uninstall LinwoodCloud.Butterfly.Nightly
```
