---
title: "Παράθυρα"
sidebar_position: 2
---

![Σταθερή έκδοση έκδοση](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Νυχτερινή έκδοση έκδοσης](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

## Ελάχιστες απαιτήσεις συστήματος

* Παράθυρα 10 ή υψηλότερη.

## Δυαδικά

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Σταθερό</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-setup-x86_64.exe">
        Ρύθμιση
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-windows-x86_64.zip">
        Φορητό
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Νυχτερινή</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-setup-x86_64.exe">
        Ρύθμιση
      </DownloadButton>
    </li>
    <li>
      <DownloadButton after="/downloads/post-windows" className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-windows-x86_64.zip">
        Φορητό
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Διαβάστε περισσότερα για τη νυχτερινή έκδοση του Butterfly [εδώ](/nightly).

## Εγκατάσταση με χρήση winget

```powershell
winget install LinwoodCloud.Butterfly
```

Για να αναβαθμίσετε το πακέτο winget, εκτελέστε:

```powershell
winget upgrade LinwoodCloud.Butterfly
```

Για να απεγκαταστήσετε το πακέτο winget, εκτελέστε:

```powershell
winget uninstall LinwoodCloud.Butterfly
```

### Νυχτερινή έκδοση

```powershell
winget install LinwoodCloud.Butterfly.Nightly
```

Για να αναβαθμίσετε το πακέτο winget, εκτελέστε:

```powershell
winget upgrade LinwoodCloud.Butterfly.Nightly
```

Για να απεγκαταστήσετε το πακέτο winget, εκτελέστε:

```powershell
winget uninstall LinwoodCloud.Butterfly.Nightly
```
