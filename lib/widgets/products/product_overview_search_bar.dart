import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class ProductOverviewSearchBar extends StatefulWidget {
  const ProductOverviewSearchBar({Key? key}) : super(key: key);

  @override
  State<ProductOverviewSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<ProductOverviewSearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;

  @override
  void initState() {
    filters = Provider.of<Filter>(context, listen: false);
    _search.text = filters.search;
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: kToolbarHeight,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        elevation: 3,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        shadowColor: Colors.transparent,
        child: TextFormField(
          controller: _search,
          maxLines: 1,
          style: TextStyle(
            fontSize: 16,
          ),
          onChanged: (textValue) {
            setState(() {
              filters.setSearch(textValue);
            });
          },
          decoration: InputDecoration(
            hintText: 'Søk',
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            suffixIcon: (_search.text == '')
                ? null
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _search = TextEditingController(text: '');
                        filters.setSearch('');
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.transparent,
            )),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
