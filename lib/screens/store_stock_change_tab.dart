import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class StoreStockChangeTab extends StatelessWidget {
  const StoreStockChangeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'Lagerendringer',
            style:
                TextStyle(color: Theme.of(context).textTheme.headline6!.color),
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
