import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../providers/filter.dart';
import '../widgets/drawer/app_drawer.dart';
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

    String _createProductSelectionText(List<String> productSelections) {
      String productSelectionText = "";
      productSelections
          .removeWhere((element) => element == "Spesialbestilling");

      if (productSelections.length == 1) {
        productSelectionText = productSelections[0];
      } else {
        productSelections.forEach(
          (element) {
            if (productSelections.indexOf(element) ==
                productSelections.length - 1) {
              productSelectionText += element;
            } else {
              productSelectionText += "${element.split('utvalget')[0]}-";
              if (productSelections.indexOf(element) <
                  productSelections.length - 2) {
                productSelectionText += ", ";
              } else {
                productSelectionText += " og ";
              }
            }
          },
        );
      }
      return productSelectionText;
    }

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
              filters.releaseList[index].productSelections.sort();
              return Column(
                children: [
                  ListTile(
                    isThreeLine: true,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          filters.releaseList[index].releaseDate != null &&
                                  DateTime.now()
                                          .difference(filters
                                              .releaseList[index].releaseDate!)
                                          .inDays <=
                                      14
                              ? Icons.new_releases
                              : Icons.new_releases_outlined,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                    iconColor: Theme.of(context).colorScheme.onBackground,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    onTap: () {
                      if (filters.filterSaveSettings[14]['save'] == false) {
                        filters.releaseSortBy = '-rating';
                        filters.releaseSortIndex =
                            'Global rating - Høy til lav';
                      }
                      filters.releaseProductSelectionChoice = '';
                      pushScreen(
                        context,
                        screen: ProductOverviewTab(
                          release: filters.releaseList[index],
                        ),
                        withNavBar: true,
                      );
                    },
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
                        if (filters
                            .releaseList[index].productSelections.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              _createProductSelectionText(
                                  filters.releaseList[index].productSelections),
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
                  if (index + 1 != filters.releaseList.length) Divider()
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
