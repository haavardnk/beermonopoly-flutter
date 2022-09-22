import 'package:flutter/material.dart';

import '../widgets/products/product_list_view.dart';

class ProductOverviewTab extends StatefulWidget {
  const ProductOverviewTab({Key? key}) : super(key: key);

  @override
  State<ProductOverviewTab> createState() => _ProductOverviewTabState();
}

class _ProductOverviewTabState extends State<ProductOverviewTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    return const ProductListView();
  }
}
