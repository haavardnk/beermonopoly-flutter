import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../assets/constants.dart';
import '../../models/release.dart';
import '../../providers/filter.dart';

class ProductOverviewReleaseProductSelection extends StatelessWidget {
  const ProductOverviewReleaseProductSelection({
    Key? key,
    required this.release,
  }) : super(key: key);

  final Release? release;

  @override
  Widget build(BuildContext context) {
    return Consumer<Filter>(
      builder: (context, filter, _) => Container(
        height: kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SegmentedButton(
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: '',
              label: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('Alle'),
              ),
            ),
            ...release!.productSelections.map((element) {
              return ButtonSegment<String>(
                value: element,
                label: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(productSelectionAbrevationList[element]!),
                ),
              );
            })
          ],
          selected: <String>{filter.releaseProductSelectionChoice},
          onSelectionChanged: (Set<String> newSelection) {
            filter.setReleaseProductSelectionChoice(newSelection.first);
          },
          showSelectedIcon: false,
          emptySelectionAllowed: true,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(3),
            surfaceTintColor: MaterialStateProperty.all<Color?>(
              Theme.of(context).colorScheme.surfaceTint,
            ),
          ),
        ),
      ),
    );
  }
}
