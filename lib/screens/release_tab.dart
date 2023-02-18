import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../providers/filter.dart';
import '../widgets/app_drawer.dart';
import '../screens/product_overview_tab.dart';

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
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: filters.getReleases,
        child: Consumer<Filter>(builder: (context, _, __) {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filters.releaseList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                    isThreeLine: true,
                    leading: Icon(Icons.new_releases),
                    trailing: Icon(Icons.arrow_forward),
                    iconColor: Theme.of(context).colorScheme.onBackground,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    onTap: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ProductOverviewTab(
                        release: filters.releaseList[index],
                      ),
                      withNavBar: true,
                    ),
                    title: Text(
                      filters.releaseList[index].releaseDate != null
                          ? '${toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO').format(filters.releaseList[index].releaseDate!))}'
                          : filters.releaseList[index].name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (filters.releaseList[index].productSelection != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Utvalg: ${filters.releaseList[index].productSelection}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Antall produkter: ${filters.releaseList[index].beerCount}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index + 1 != filters.releaseList.length)
                    Divider(
                      height: 0,
                      color: Colors.grey[400],
                    )
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
