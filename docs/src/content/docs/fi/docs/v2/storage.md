---
title: Tallennustila
sidebar_position: 2
---

## Datakansio

Tietokansio on hakemisto, johon asiakirjoja, malleja ja paketteja tallennetaan.
Työpöydältä löydät sen osoitteesta `~/Documents/Linwood/Butterfly`.
Mobiilissa se on muodossa `getExternalFilesDir(null)/Linwood/Butterfly`.
Voit myös muuttaa sitä asetuksissa kohdassa `Data`.

Tästä hakemistosta löydät kansion `Dokumentit`, `Templates` ja `Packs`.

## Verkko

Sovelluksen tiedot on tallennettu selaimeesi. Se on tallennettu paikalliseen tallennustilaan.
Avaa kehittäjän työkalut selaimessasi ja näet niiden tiedot.

## Natiivi alustat

Oletuksena sovellus tallentaa asiakirjojesi kansiossa olevat tiedot "Linwood/Butterfly" -kansion alikansioon. Tämä kansio on luotu, kun tallennat ensimmäiset tiedot. Tätä kansiota voidaan muuttaa asetuksissa.

## Etätallennustila {#remote}

:::note

Tämä ominaisuus ei ole käytettävissä verkossa.

:::

Sovellus voidaan tallentaa myös etäpalvelimelle. Tämä on hyödyllistä, jos haluat jakaa tietoja muiden ihmisten kanssa tai jos sinulla on useita tietokoneita. Tällä hetkellä vain `WebDAV`-protokolla on tuettu.

Jos haluat lisätä etäpalvelimen, siirry asetuksiin ja napsauta `Remotes`. Klikkaa sitten `Add remote`.
Lisää etäpalvelimen URL ja käyttäjätunnus ja salasana. Sen jälkeen voit määrittää kansion, jossa tiedot tallennetaan.

Jos haluat saada webdav url, käy dokumentaatio:

- [Nextcloud](https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html) (sen pitäisi näyttää tältä: `https://nextcloud.example.com/remote.php/dav/files/username/`, korvaa `username` ja `nextcloud.example.com` oikeilla arvoilla)

### Offline sync {#offline}

Tämän ominaisuuden avulla voit muokata tiedostoja etäpalvelimilla ollessasi offline-tilassa.
Avaa ponnahdusikkunavalikko tiedostossa tai kansiossa ja napsauta `Sync`. Tämä lataa tiedoston tai kansion ja tallentaa sen paikallisesti. Synkronoidaksesi koko juurihakemiston, klikkaa valintaruutua luomalla valintaikkunassa tai klikkaa kaukosäätimen asetusta ja klikkaa valintaruutua sen hallinta-osiossa. @ info: whatsthis

On olemassa muutamia rajoituksia:

- Voit synkronoida vain hakemiston ylätason arvon. Jos sinulla on esimerkiksi hakemisto `a/b/test.bfly`, tätä tiedostoa ei synkronoida.
- Et voi poistaa tiedostoa tai kansiota offline-tilassa.
- Et voi lisätä, muokata tai poistaa malleja ollessasi offline-tilassa.

## Muut varastointimenetelmät

Jos olet kotoperäisellä laitteella, voit myös synkronoida sovelluksen hakemiston suosikki alustan.
Google-asemalla on [virallinen sovellus](https://www.google.com/drive/download/) ikkunoissa, ja näytelmäkaupassa on epävirallisia otteita.
Linuxissa voit myös käyttää natiivia etätallennusjärjestelmää ja vaihtaa datahakemiston tähän tai lisätä uuden ulkoisen tallennustilan, jos klikkaat yhteys-painiketta.
