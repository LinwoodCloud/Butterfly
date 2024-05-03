---
title: Bädda in
sidebar_label: Introduktion
---

Inbäddning är ett enkelt sätt att inkludera appen på din webbplats. Lägg till följande kod på din webbplats:

```html
<iframe src="https://web.butterfly.linwood.dev/embed" width="100%" height="500px" allowtransparency="true"></iframe>
```

## Alternativ

| Alternativ | Typ                             | Standard | Beskrivning                                                                                                                                             |
| ---------- | ------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| spara      | Boolesk (sant, falskt)          | sant     | Aktivera spara. Om inaktiverad, visas endast en avgångsknapp                                                                                            |
| redigerbar | Boolesk (sant, falskt)          | sant     | Aktivera redigering. Om inaktiverad, kommer dokumentet att skrivas enbart                                                                               |
| språk      | Sträng (..., system, användare) | system   | Språk i dokumentet. Om systemet, kommer språket att upptäckas från webbläsaren. Om användaren kommer språket att ställas in efter användarens preferens |

## Händelser

Exempel på hur du använder den:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.addEventListener('message', (data) => {
  if(data.detail.type === 'save') {
    console.log('Spara...', data.detail.message);
  }
});
```

### spara

> Händelsen `spara` släpps ut när användaren klickar på knappen Spara.

Parametrar:

* `data` (Typ `Lista<int>`): Dokumentets data.

### avsluta

> Händelsen `exit` avges när användaren klickar på utgångsknappen.

Parametrar:

* `data` (Typ `Lista<int>`): Dokumentets data.

### ändra

> Händelsen `ändra` släpps ut när användaren ändrar dokumentet.

Parametrar:

* `data` (Typ `Lista<int>`): Dokumentets data.

## Metoder

Exempel på hur du använder den:

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

> Metoden `getData` returnerar data från dokumentet.

Inga parametrar. Returer: `Lista<int>`

### setData

> Metoden `setData` anger data för dokumentet.

Parametrar:

* `data` (Typ `Lista<int>`): Dokumentets data.

### renderare

> Metoden `render` renderar dokumentet till en png bild.

Parametrar:

* `bredd` (Typ `Nummer`): Bredden på bilden.
* `höjd` (Typ `Nummer`): Höjden på bilden.
* `skala` (Typ `Nummer`): Skalan på bilden.
* `renderBakgrund` (Typ `Boolesk`): Om sann kommer bakgrunden att renderas.

Returer: `Sträng` (Base64-kodad bild)

### renderSVG

> Metoden `renderSVG` renderar dokumentet till en svg-bild.

Parametrar:

* `bredd` (Typ `Nummer`): Bredden på bilden.
* `höjd` (Typ `Nummer`): Höjden på bilden.
* `renderBakgrund` (Typ `Boolesk`): Om sann kommer bakgrunden att renderas.

Returer: `Sträng` (SVG)
