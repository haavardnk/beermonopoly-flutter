import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../providers/filter.dart';
import '../widgets/drawer/app_drawer.dart';
import '../screens/product_overview_tab.dart';
import '../models/release.dart';

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
    List<int> years = [];

    void _getReleaseYears() {
      filters.releaseList.forEach((release) {
        if (years.contains(release.releaseDate!.year)) {
          return;
        }
        years.add(release.releaseDate!.year);
      });
    }

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
        child: Consumer<Filter>(
          builder: (context, _, __) {
            _getReleaseYears();
            return ListView(
              children: [
                for (int year in years)
                  ExpansionTile(
                    title: Text(
                      year.toString(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: year == years[0] ? true : false,
                    shape: const Border(),
                    children: [
                      for (Release release in filters.releaseList)
                        if (release.releaseDate!.year == year)
                          Column(
                            children: [
                              ListTile(
                                isThreeLine: true,
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      release.releaseDate != null &&
                                              DateTime.now()
                                                      .difference(
                                                          release.releaseDate!)
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
                                iconColor:
                                    Theme.of(context).colorScheme.onBackground,
                                textColor:
                                    Theme.of(context).colorScheme.onBackground,
                                onTap: () {
                                  if (filters.filterSaveSettings[14]['save'] ==
                                      false) {
                                    filters.releaseSortBy = '-rating';
                                    filters.releaseSortIndex =
                                        'Global rating - Høy til lav';
                                  }
                                  filters.releaseProductSelectionChoice = '';
                                  pushScreen(
                                    context,
                                    screen: ProductOverviewTab(
                                      release: release,
                                    ),
                                    withNavBar: true,
                                  );
                                },
                                title: Text(
                                  release.releaseDate != null
                                      ? '${toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO').format(release.releaseDate!))}'
                                      : release.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (release.productSelections.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          _createProductSelectionText(
                                              release.productSelections),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        'Antall produkter: ${release.beerCount}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (release.name !=
                                      filters.releaseList.last.name &&
                                  release.releaseDate!.year ==
                                      filters
                                          .releaseList[filters.releaseList
                                                  .indexOf(release) +
                                              1]
                                          .releaseDate!
                                          .year)
                                Divider()
                            ],
                          ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
