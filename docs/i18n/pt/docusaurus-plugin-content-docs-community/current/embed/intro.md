---
title: Incorporar
sidebar_label: Introdução
---

Embutir é uma maneira simples de incluir o aplicativo em seu site. Adicione o seguinte código ao seu site:

```html
<iframe src="https://web.butterfly.linwood.dev/embed" width="100%" height="500px" allowtransparency="true"></iframe>
```

## Opções

| Alternativa | tipo                           | Padrão     | Descrição:                                                                                                                                     |
| ----------- | ------------------------------ | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Salvar      | Booleano (true, false)         | verdadeiro | Habilitar salvamento. Se desativado, somente um botão de saída será mostrado                                                                   |
| editável    | Booleano (true, false)         | verdadeiro | Habilitar edição. Se desativado, o documento será somente leitura                                                                              |
| Idioma      | String (..., sistema, usuário) | Sistema    | Idioma do documento. Se o sistema, o idioma será detectado do navegador. Se o usuário, o idioma será ajustado para as preferências de usuários |

## Eventos

Exemplo de como usá-lo:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.addEventListener('message', (data) => {
  if(data.detail.type === 'save') {
    console.log('Salvar...', data.detail.message);

});
```

### Salvar

> O evento `salvar` é emitido quando o usuário clica no botão salvar.

Parâmetros:

* `dados` (Tipo `Lista<int>`): Os dados do documento.

### saindo

> O evento `exit` é emitido quando o usuário clica no botão de sair.

Parâmetros:

* `dados` (Tipo `Lista<int>`): Os dados do documento.

### Alterar

> O evento `alterar` é emitido quando o usuário altera o documento.

Parâmetros:

* `dados` (Tipo `Lista<int>`): Os dados do documento.

## Métodos

Exemplo de como usá-lo:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.pushMessage('getData', {});
embedElement.addEventListener('message', (data) => {
  if(data.detail.type === 'getData') {
    console.log(data.detail.message);
  }
});
```

### getData

> O método `getData` retorna os dados do documento.

Nenhum parâmetro. Retorna: `Lista<int>`

### definirDados

> O método `setData` define os dados do documento.

Parâmetros:

* `dados` (Tipo `Lista<int>`): Os dados do documento.

### renderizar

> O método `render` renderiza o documento em uma imagem png

Parâmetros:

* `largura` (Tipo `Número`): A largura da imagem.
* `height` (Tipo `Number`): A altura da imagem.
* `scale` (Type `Number`): A escala da imagem.
* `renderBackground` (Tipo `Boolean`): Se verdadeiro, o fundo será renderizado.

Retorna: `String` (imagem codificada em Base64)

### renderização

> O método `renderSVG` renderiza o documento a uma imagem svg.

Parâmetros:

* `largura` (Tipo `Número`): A largura da imagem.
* `height` (Tipo `Number`): A altura da imagem.
* `renderBackground` (Tipo `Boolean`): Se verdadeiro, o fundo será renderizado.

Retorna: `String` (SVG)
