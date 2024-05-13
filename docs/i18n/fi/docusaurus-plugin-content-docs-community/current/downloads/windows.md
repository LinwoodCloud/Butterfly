---
title: "Ikkunat"
sidebar_position: 2
---

![Vakaa julkaisuversio](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Nightly release version](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

## Järjestelmää koskevat vähimmäisvaatimukset

* Windows 10 tai uudempi.

## Binaries

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Vakaa</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-setup-x86_64.exe">
        Asetukset
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-x86_64.zip">
        Kannettava
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Yöllä</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-setup-x86_64.exe">
        Asetukset
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-x86_64.zip">
        Kannettava
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Lue lisää Butterfly yöllisestä versiosta [täältä](/nightly).

## Asenna siivekkeellä

```powershell
winget install LinwoodCloud.Butterfly
```

Päivittääksesi winget-paketin, suorita:

```powershell
winget upgrade LinwoodCloud.Butterfly
```

Voit poistaa winget-paketin, suorita:

```powershell
winget uninstall LinwoodCloud.Butterfly
```

### Yöllinen versio

```powershell
winget install LinwoodCloud.Butterfly.Nightly
```

Päivittääksesi winget-paketin, suorita:

```powershell
winget upgrade LinwoodCloud.Butterfly.Nightly
```

Voit poistaa winget-paketin, suorita:

```powershell
winget uninstall LinwoodCloud.Butterfly.Nightly
```
