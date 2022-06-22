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
          style: TextStyle(color: Theme.of(context).textTheme.headline6!.color),
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
              "Ølmonopolet er en app som kontinuerlig samler data fra Vinmonopolet og Untappd "
              "for å tilby en tjeneste som skal hjelpe deg å finne det beste ølet på lager til en hver tid. ",
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
              "Data fra Vinmonopolet blir oppdatert en gang i døgnet. "
              "Det inkluderer informasjon om øl, utvalg og lagerstatus. "
              "Når på døgnet denne dataen blir oppdatert varierer og er spredt utover.",
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
              "Data fra Untappd blir oppdatert kontinuerlig gjennom hele døgnet. "
              "Dette gjøres fordi Untappd har en ganske lav API grense. "
              "Øl blir derfor oppdatert rullerende etter hvilken som ble oppdatert sist, "
              "med ekstra prioritet til nye øl og øl med få innsjekkinger. "
              "Når du først logger inn med Untappd vil alle dine innsjekkinger bli hentet. "
              "Dette kan ta noe tid og avhenger av hvor mange innsjekkinger du har. "
              "Etter dette blir alle nye innsjekkinger hentet en gang i døgnet. "
              "Ønskelisten og vennelisten din vil også bli hentet en gang i døgnet.",
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Ølmonopolet's algoritme for å matche øl mellom Vinmonopolet og Untappd er bra, men ikke perfekt."
                " Du kan derfor komme over øl hvor metadata er feil. Dette kan du rapportere med knappen"
                " 'Rapporter feil Untappd match' innpå detaljsiden til hvert enkelt øl."),
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
              "Denne applikasjonen er 100% avhengig av ekstern data. "
              "Dersom data tilgjengeligheten av en eller annen grunn skulle "
              "forsvinne fra en av de eksterne datakildene vil denne applikasjonen derfor slutte å fungere.",
            ),
          ],
        ),
      ),
    );
  }
}
