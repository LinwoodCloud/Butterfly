---
title: "Linux"
sidebar_position: 3
---

![Стабильная версия релиза](https://img.shields.io/badge/dynamic/yaml?color=c4840d&label=Stable&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml&style=for-the-badge) ![Ночной релиз версии](https://img.shields.io/badge/dynamic/yaml?color=f7d28c&label=Nightly&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml&style=for-the-badge)

::note

Пожалуйста, используйте версию flatpak, если это возможно. В противном случае вам нужно установить `libsecret-1-dev` и `libjsoncpp-dev`.

:::

## Сборки

<div className="row margin-bottom--lg padding--sm">
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--info button--lg">Стабильная</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux.tar.gz">
        Портативный
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux.deb">
        ДЕБ
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux.rpm">
        РПМ
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/stable/linwood-butterfly-linux.AppImage">
        AppImage
      </DownloadButton>
    </li>
  </ul>
</div>
<div className="dropdown dropdown--hoverable margin--sm">
  <button className="button button--outline button--danger button--lg">Ночной</button>
  <ul className="dropdown__menu">
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.tar.gz">
        Портативный
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.deb">
        ДЕБ
      </DownloadButton>
    </li>
    <li>
      <DownloadButton className="dropdown__link" href="https://github.com/LinwoodDev/butterfly/releases/download/nightly/linwood-butterfly-linux-x86_64.rpm">
        РПМ
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

Подробнее о ночной версии Butterfly [здесь](/nightly).

## Магазин

<div className="row margin-bottom--lg padding--sm">
<Link className="button button--outline button--primary button--lg margin--sm" href="https://flathub.org/apps/details/dev.linwood.butterfly">
  Flathub
</Link>
<Link className="button button--outline button--primary button--lg margin--sm" href="https://snapcraft.io/butterfly">
  Snap
</Link>
</div>

Ночная версия также доступна на бета-репозитории flathub. Read more about the flathub beta repository [here](https://discourse.flathub.org/t/how-to-use-flathub-beta/2111).
