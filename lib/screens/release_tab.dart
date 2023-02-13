import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../providers/filter.dart';
import '../widgets/app_drawer.dart';

class ReleaseTab extends StatefulWidget {
  const ReleaseTab({Key? key}) : super(key: key);

  @override
  State<ReleaseTab> createState() => _ReleaseTabState();
}

class _ReleaseTabState extends State<ReleaseTab> {
  @override
  void initState() {
    initializeDateFormatting('nb_NO', null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late Filter filters = Provider.of<Filter>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'Nyhetslanseringer',
            style:
                TextStyle(color: Theme.of(context).textTheme.headline6!.color),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filters.releaseList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO').format(filters.releaseList[index].release_date!))}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Utvalg: ${filters.releaseList[index].product_selection}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Antall produkter: ${filters.releaseList[index].beer_count}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0,
                color: Colors.grey[400],
              )
            ],
          );
        },
      ),
    );
  }
}
