---
title: "Linux"
sidebar_position: 3
---

![Stabilní verze vydání](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Nightly release verze](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

:::note

Pokud je to možné, použijte flatpak verzi. Jinak musíte nainstalovat `libsecret-1-dev` a `libjsoncpp-dev`.

:::

## Binární soubory

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Stabilní</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux-x86_64.tar.gz">
        Přenosné
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux-x86_64.deb">
        SP
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux-x86_64.rpm">
        RPM
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux-x86_64.AppImage">
        AppImage
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Noční</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.tar.gz">
        Přenosné
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.deb">
        SP
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.rpm">
        RPM
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.AppImage">
        AppImage
      </DownloadButton>
    </li>
  </ul>
</div>
</div>

Přečtěte si více o noční verzi Butterfly [zde](/nightly).

## Obchody

<div className="row margin-bottom--lg padding--sm">
<Link className="button button--outline button--primary button--lg margin--sm" href="https://flathub.org/apps/details/dev.linwood.butterfly">
  Flathub
</Link>
<Link className="button button--outline button--primary button--lg margin--sm" href="https://snapcraft.io/butterfly">
  zachytit
</Link>
</div>

Nightly verze je také k dispozici v repozitáři flathub beta verze. Přečtěte si více o banthub beta repozitáři [zde](https://discourse.flathub.org/t/how-to-use-flathub-beta/2111).
