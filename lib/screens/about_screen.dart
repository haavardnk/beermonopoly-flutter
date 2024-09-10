import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Om Ølmonopolet',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme:
            Theme.of(context).appBarTheme.iconTheme, //change your color here
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Informasjon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "Ølmonopolet er en app som kontinuerlig innhenter data fra Vinmonopolet og Untappd "
              "for å gi deg den best mulige tjenesten for å finne det beste ølet som er på lager til enhver tid.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Data fra Vinmonopolet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Data fra Vinmonopolet blir oppdatert jevnlig, minst en gang per dag. "
              "Denne informasjonen inkluderer detaljer om ølutvalg og lagerstatus. "
              "Nøyaktig når dataen oppdateres kan variere fra dag til dag.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Data fra Untappd',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Untappd-data blir kontinuerlig oppdatert gjennom hele døgnet på grunn av deres lave API-grense. "
                "Øl blir derfor oppdatert i henhold til når de ble oppdatert sist, "
                "med ekstra prioritet for nye øl og øl med få innsjekkinger. "
                // "Når du logger inn med Untappd for første gang, vil alle dine innsjekkinger bli hentet. "
                // "Dette kan ta noe tid og avhenger av hvor mange innsjekkinger du har. "
                // "Etter dette vil alle nye innsjekkinger bli hentet inn en gang per dag. "
                // "Din ønskeliste og venneliste vil også bli hentet inn en gang per dag.",
                ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Ølmonopolet's algoritme for å matche øl mellom Vinmonopolet og Untappd er god, men ikke perfekt. "
              "Derfor kan du støte på øl hvor metadataen er feil. Du kan rapportere dette ved å bruke knappen "
              "'Rapporter feil Untappd match' på detaljsiden for hvert enkelt øl.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Vilkår',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Denne applikasjonen er fullstendig avhengig av ekstern data. "
              "Hvis data fra en av de eksterne datakildene skulle bli utilgjengelig av en eller annen grunn, "
              "vil applikasjonen slutte å fungere.",
            ),
          ],
        ),
      ),
    );
  }
}
