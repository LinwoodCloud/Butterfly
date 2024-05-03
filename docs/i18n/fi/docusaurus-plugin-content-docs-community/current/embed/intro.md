---
title: Upota
sidebar_label: Esittely
---

Upottaminen on yksinkertainen tapa sisällyttää sovellus sivustoosi. Lisää seuraava koodi sivustollesi:

```html
<iframe src="https://web.butterfly.linwood.dev/embed" width="100%" height="500px" allowtransparency="true"></iframe>
```

## Valinnat

| Valinta       | Tyyppi                                  | Oletus      | Kuvaus                                                                                                                    |
| ------------- | --------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| tallenna      | Totuus (tosi, epäto)                    | tosi        | Ota tallennus käyttöön. Jos poistettu käytöstä, näytetään vain poistumispainike                                           |
| muokattavissa | Totuus (tosi, epäto)                    | tosi        | Ota muokkaus käyttöön. Jos poistettu käytöstä, asiakirja on vain luku                                                     |
| kieli         | Merkkijono (..., järjestelmä, käyttäjä) | järjestelmä | Asiakirjan kieli. Jos järjestelmä, kieli havaitaan selaimesta käsin. Jos käyttäjä, kieli asetetaan käyttäjien asetukseksi |

## Tapahtumat

Esimerkkejä siitä, miten sitä käytetään:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.addEventListener('message', (data) => {
  if(data.detail.type == 'save') {
    console.log('Saving...', data.detail.message);
  }
});
```

### tallenna

> The `save` event is emitted when user click the save button. (Automatic Copy)

Parametrit:

* `data` (Kirjoita `Luettelo<int>`): Asiakirjan tiedot.

### poistu

> Tapahtuma `exit` on lähetetty, kun käyttäjä klikkaa poistumispainiketta.

Parametrit:

* `data` (Kirjoita `Luettelo<int>`): Asiakirjan tiedot.

### muuta

> The `change` event is emitted when user change the document. (Automatic Copy)

Parametrit:

* `data` (Kirjoita `Luettelo<int>`): Asiakirjan tiedot.

## Menetelmät

Esimerkki siitä, miten sitä käytetään:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.pushMessage('getData', {});
embedElement.addEventListener('message', (data) => {
  if(data.detail.type == = 'getData') {
    console.log(data.detail.message);
  }
});
```

### getData

> The `getData` method palauttaa asiakirjan tiedot.

Ei parametreja. Palautukset: `Luettelo<int>`

### setData

> The `setData` method set the data of the document.

Parametrit:

* `data` (Kirjoita `Luettelo<int>`): Asiakirjan tiedot.

### renderöi

> The `render` method rmakes the document to a png image.

Parametrit:

* `leveys` (Tyyppi `Numero`): Kuvan leveys.
* `korkeus` (Tyyppi `Numero`): Kuvan korkeus.
* `skaalaus` (Tyyppi `Numero`): Kuvan skaala.
* `renderöintiTausta` (Kirjoita `Boolean`): Jos tosi, tausta renderöidään.

Palautukset: `Merkkijono` (64 koodattu kuva)

### renderSVG

> The `renderSVG` method renderöi asiakirjan svg image.

Parametrit:

* `leveys` (Tyyppi `Numero`): Kuvan leveys.
* `korkeus` (Tyyppi `Numero`): Kuvan korkeus.
* `renderöintiTausta` (Kirjoita `Boolean`): Jos tosi, tausta renderöidään.

Palautukset: `Merkkijono` (SVG)
