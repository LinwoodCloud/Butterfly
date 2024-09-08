---
title: Selfhosting
---

![Stable release version](https://img.shields.io/badge/dynamic/yaml?color=c4840d\&label=Stable\&query=%24.version\&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml\&style=for-the-badge)
![Nightly release version](https://img.shields.io/badge/dynamic/yaml?color=f7d28c\&label=Nightly\&query=%24.version\&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml\&style=for-the-badge)

托管您自己的蝴蝶

## 简单服务器

安装流体并使用以下方式构建应用：

```bash
cd app
flutter pub get
flutter build web
```

所有文件都在 `app/build/web` 目录中。

## 停靠栏

复制仓库并使用 `docker build-t linwood-butterfly` 构建`Dockerfile` 。
启动服务器使用: `docker运行 -p 8080:8080 -d linwood-butterfly` 。
