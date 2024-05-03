---
title: "Armazenamento"
sidebar_position: 2
---

## Diretório de dados

O diretório de dados é o diretório onde documentos, modelos e pacotes são armazenados. No desktop você pode encontrá-lo em `~/Documents/Linwood/Butterfly`. Em mobile é em `getExternalFilesDir(null)/Linwood/Butterfly`. Você também pode alterá-lo nas configurações em `Dados`.

Neste diretório, você encontrará uma pasta `Documents`, `Templates` e `Packs`.

## Web

Os dados do aplicativo são armazenados no seu navegador. Ele é armazenado em um armazenamento local. Abra as ferramentas de desenvolvedor no seu navegador e você verá os dados.

## Plataformas nativas

Como padrão, a aplicação salva os dados na pasta de documentos em uma subpasta chamada "Linwood/Butterfly". Esta pasta é criada quando você salva os primeiros dados. Esta pasta pode ser alterada nas configurações.

## Armazenamento remoto {#remote}

:::nota

Este recurso não está disponível na web.

:::

O aplicativo pode ser salvo em um servidor remoto. Isso é útil se você quiser compartilhar os dados com outras pessoas ou se você tiver vários computadores. Atualmente, apenas o `protocolo` WebDAV é suportado.

Para adicionar um servidor remoto, vá para configurações e clique em `Remotos`. Então clique em `Adicionar controle remoto`. Adicione a URL do servidor remoto e o nome de usuário e senha. Depois disso, você pode especificar a pasta onde os dados são armazenados.

Para obter o URL do webdav, por favor, visite a documentação:

* [Nextcloud](https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html) (deve se parecer com isto: `https://nextcloud.example.com/remote.php/dav/files/username/`, substitua `nome de usuário` e `nextcloud.example.com` com os valores corretos)

### Sincronização offline {#offline}

Este recurso permite que você edite seus arquivos em servidores remotos enquanto estiver offline. Abra o menu pop-up em um arquivo ou pasta e clique em `Sincronizar`. Isto irá baixar o arquivo ou pasta e salvá-lo localmente. Para sincronizar todo o diretório raiz, clique na marca de seleção na caixa de diálogo Criar ou clique no controle remoto na configuração e clique na marca de seleção na seção Gerenciar.

Existem algumas limitações:

* Você só pode sincronizar o nível superior de um diretório. Por exemplo, se você tiver o diretório `a/b/test.bfly`, este arquivo não será sincronizado.
* Não é possível excluir um arquivo ou pasta enquanto você está offline.
* Você não pode adicionar, editar ou excluir modelos enquanto estiver offline.

## Outros métodos de armazenamento

Se você está em um dispositivo nativo, também pode sincronizar o diretório do aplicativo com a sua plataforma favorita. O Google Drive possui [um aplicativo oficial](https://www.google.com/drive/download/) nas janelas e há ondas não oficiais na Play Store. No Linux, você também pode usar o sistema de armazenamento remoto nativo e alterar o diretório de dados para isto ou adicionar um novo armazenamento externo se você clicar no botão adicionar conexão.
