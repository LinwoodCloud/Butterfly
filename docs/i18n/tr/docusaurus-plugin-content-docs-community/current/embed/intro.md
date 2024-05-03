---
title: Yerleştirme
sidebar_label: Başlangıç
---

Yerleştirme işlemi, uygulamayı web sitenize dahil etmenin basit bir yoludur. Aşağıdaki kodu web sitenize ekleyin:

```html
<iframe src="https://web.butterfly.linwood.dev/embed" width="100%" height="500px" allowtransparency="true"></iframe>
```

## Şeçenekler

| Seçenek  | Tür                        | Varsayılan | Tanım                                                                                                                             |
| -------- | -------------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------- |
| save     | Boolean (true, false)      | true       | Kaydetmeyi etkinleştirin. Eğer devre dışı bırakılırsa, yalnızca bir çıkış düğmesi gösterilir                                      |
| editable | Boolean (true, false)      | true       | Düzenlemeyi etkinleştir. Eğer devre dışı bırakılırsa, belge salt okunur olur                                                      |
| language | String (..., system, user) | system     | Belge dili. Eğer sistem ise, dil tarayıcıdan algılanacaktır. Eğer kullanıcı ise, dil kullanıcıların tercihine göre ayarlanacaktır |

## Etkinlikler

Nasıl kullanılacağına dair örnekler:

```javascript
const embedElement = document.querySelector('#butterfly');
embedElement.addEventListener('message', (data) => {
  if(data.detail.type === 'save') {
    console.log('Saving...', data.detail.message);
  }
});
```

### save

> Kullanıcı kaydet düğmesini tıkladığında `save` olayı yayınlanır.

Parametreler:

* `data` (Type `List<int>`): The data of the document.

### exit

> Kullanıcı çıkış düğmesini tıkladığında `exit` olayı yayınlanır.

Parametreler:

* `data` (Type `List<int>`): The data of the document.

### change

> Kullanıcı belgeyi değiştirdiğinde `change` olayı yayınlanır.

Parametreler:

* `data` (Type `List<int>`): The data of the document.

## Yöntemler

Nasıl kullanılacağına dair örnekler:

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

> `getData` yöntemi, belgenin verilerini döndürür.

Parametre yok. Returns: `List<int>`

### setData

> `setData` yöntemi, belgenin verilerini ayarlar.

Parametreler:

* `data` (Type `List<int>`): The data of the document.

### render

> `render` yöntemi, belgeyi bir png görüntüsüne dönüştürür.

Parametreler:

* `width` (Type `Number`): Görselin genişliği.
* `height` (Type `Number`): Görselin yüksekliği.
* `scale` (Type `Number`): Görselin ölçeği.
* `renderBackground` (Type `Boolean`): Eğer doğruysa, arka plan oluşturulacaktır.

Dönüş: `String` (Base64 ile kodlanmış görsel)

### renderSVG

> `renderSVG` yöntemi, belgeyi bir svg görüntüsüne dönüştürür.

Parametreler:

* `width` (Type `Number`): Görselin genişliği.
* `height` (Type `Number`): Görselin yüksekliği.
* `renderBackground` (Type `Boolean`): Eğer doğruysa, arka plan oluşturulacaktır.

Dönüş: `String` (SVG)
