import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/release.dart';
import '../../providers/filter.dart';
import '../../providers/auth.dart';
import '../../assets/constants.dart';

class ReleaseSort extends StatefulWidget {
  final Release release;
  const ReleaseSort(this.release, {Key? key}) : super(key: key);

  @override
  State<ReleaseSort> createState() => _ReleaseSortState();
}

class _ReleaseSortState extends State<ReleaseSort> {
  late final filters = Provider.of<Filter>(context, listen: false).filters;
  late final Auth authData = Provider.of<Auth>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Consumer<Filter>(
                            builder: (context, _, __) {
                              return SwitchListTile(
                                contentPadding:
                                    EdgeInsets.only(left: 12, right: 4),
                                title: Text(
                                  'Husk valgt sortering',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: filters.filterSaveSettings[14]['save'],
                                onChanged: (bool newValue) {
                                  filters.filterSaveSettings[14]['save'] =
                                      newValue;
                                  filters.saveFilterSettings();
                                },
                              );
                            },
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sortList.length,
                              itemBuilder: (context, index) =>
                                  RadioListTile<String>(
                                title: Text(sortList.keys.toList()[index]),
                                value: sortList.keys.toList()[index],
                                groupValue: filters.releaseSortIndex,
                                onChanged: (String? x) {
                                  filters.releaseSortIndex = x!;
                                  filters.setSortBy(x, true);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.sort)),
      ],
    );
  }
}
