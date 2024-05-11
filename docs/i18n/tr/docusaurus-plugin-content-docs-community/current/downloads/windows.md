---
title: "Windows"
sidebar_position: 2
---

![Kararlı sürüm](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Nightly release version](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

## Minimum sistem gereksinimleri

* Windows 10 veya üstü.

## Depolar

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Kararlı</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-setup-x86_64.exe">
        Kurulum
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-x86_64.zip">
        Taşınabilir (Portable)
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Nightly</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-setup-x86_64.exe">
        Kurulum
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-x86_64.zip">
        Taşınabilir (Portable)
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Butterfly'ın nightly sürümü hakkında daha fazla bilgiyi [buradan](/nightly) okuyun.

## Winget kullanarak yükleyin

```powershell
winget install LinwoodCloud.Butterfly
```

Winget paketini yükseltmek için şunu çalıştırın:

```powershell
winget upgrade LinwoodCloud.Butterfly
```

Winget paketini kaldırmak için şunu çalıştırın:

```powershell
winget uninstall LinwoodCloud.Butterfly
```

### Nightly version

```powershell
winget install LinwoodCloud.Butterfly.Nightly
```

Winget paketini yükseltmek için şunu çalıştırın:

```powershell
winget upgrade LinwoodCloud.Butterfly.Nightly
```

Winget paketini kaldırmak için şunu çalıştırın:

```powershell
winget uninstall LinwoodCloud.Butterfly.Nightly
```
