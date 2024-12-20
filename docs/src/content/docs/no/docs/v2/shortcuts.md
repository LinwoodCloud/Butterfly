---
title: Snarveier
---

## Keyboard

Det er noen snarveier du kan benytte i editoren.
Noen av dem er skrevet under knappene.

### Generelt

- `Ctrl` + `N`: Ny fil
- `Ctrl` + `Shift` + `N`: Ny fil fra mal
- `Ctrl` + `E`: Eksporter fil
- `Ctrl` + `P`: Skriv ut fil
- `Ctrl` + `Shift` + `E`: Eksporter som bilde
- `Ctrl` + `Alt` + `E`: Eksporter filen som svg
- `Ctrl` + `Alt` + `Shift` + `E`: Export file as pdf
- `Ctrl` + `Alt` + `P`: Åpne pakker
- `Ctrl` + `Alt` + `S`: Åpne innstillinger

### Prosjekt

- `Ctrl` + `K`: Open search
- `Ctrl` + `Z`: Angre
- `Ctrl` + `Y`: Omgjør
- `Ctrl` + `Shift` + `P`: Open waypoint dialog
- `Ctrl` + `B`: Åpne bakgrunnsdialog
- `Ctrl` + `S`: lagre
- `Alt` + `S`: Endringsbane
- `Ctrl` + (`1` - `0`): Bytt til verktøy
- `Ctrl` + `+`: Zoom inn
- `Ctrl` + `-`: Zoom ut

## Penn

Som standard konfigureres pennen til å fungere som følgende:

- En penn: konfigurert som penn.
- `Først` (Primærknapp, hvis støttet): Bytt til håndverktøy mens du trykker.
- `Second` (Secondary button, if supported): Change to second tool (see [configure](#configure) section below) while pressed.

## Konfigurer {#configure}

Du kan tilpasse kontrollene ved å gi hver kontroll en verktøyindeks. Verktøyet som indekserer fra venstre av verktøylinjen, starter med at '1' er den første indeksen. Se eksempelet nedenfor

\==verktøylinje nummerert](toolbar_numbered.png)

Her viser 1 til lassoverktøyet 2, til panserverktøyet osv.

Konfigurere innstillingene du har er følgende:

- Tom - verktøyet er ubelastet.
- 0 - verktøyet fungerer som flytting (dvs. hånd) i denne moden.
- Positivt nummer - Verktøyet vil følge indekseringen som forklarer ovenfor.
