import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../helpers/api_helper.dart';
import './product_item.dart';
import '../../models/product.dart';
import '../../providers/filter.dart';
import '../../providers/auth.dart';
import './pagination_indicators/first_page_error_indicator.dart';
import './pagination_indicators/new_page_error_indicator.dart';
import './pagination_indicators/no_items_found_indicator.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late int _pageSize;
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 5);

  Future<void> _fetchPage(int pageKey, Filter filters, Auth auth) async {
    try {
      final newItems =
          await ApiHelper.getProductList(pageKey, filters, auth, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQueryData = MediaQuery.of(context);
    _pageSize = _mediaQueryData.size.width ~/
                (350 + _mediaQueryData.textScaleFactor * 21) >=
            2
        ? 24
        : 14;
    _pagingController.addPageRequestListener((pageKey) {
      final filters = Provider.of<Filter>(context, listen: false).filters;
      final auth = Provider.of<Auth>(context, listen: false);
      _fetchPage(pageKey, filters, auth);
    });

    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Consumer<Filter>(
        builder: (context, value, _) {
          _pagingController.refresh();
          return _mediaQueryData.size.width < 600
              ? PagedListView<int, Product>.separated(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Product>(
                    animateTransitions: true,
                    transitionDuration: const Duration(milliseconds: 300),
                    itemBuilder: (context, item, index) => ProductItem(
                      product: item,
                    ),
                    firstPageErrorIndicatorBuilder: (_) =>
                        FirstPageErrorIndicator(
                      onTryAgain: () => _pagingController.refresh(),
                    ),
                    newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                      onTap: () => _pagingController.retryLastFailedRequest(),
                    ),
                    noItemsFoundIndicatorBuilder: (_) =>
                        const NoItemsFoundIndicator(),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    height: 0,
                    color: Colors.grey[400],
                  ),
                )
              : PagedGridView<int, Product>(
                  pagingController: _pagingController,
                  showNewPageProgressIndicatorAsGridChild: false,
                  showNewPageErrorIndicatorAsGridChild: false,
                  showNoMoreItemsIndicatorAsGridChild: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 100 + _mediaQueryData.textScaleFactor * 48,
                    crossAxisCount: _mediaQueryData.size.width ~/
                                (350 + _mediaQueryData.textScaleFactor * 21) <=
                            4
                        ? _mediaQueryData.size.width ~/
                            (350 + _mediaQueryData.textScaleFactor * 21)
                        : 4,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<Product>(
                    animateTransitions: true,
                    transitionDuration: const Duration(milliseconds: 300),
                    itemBuilder: (context, item, index) => ProductItem(
                      product: item,
                    ),
                    firstPageErrorIndicatorBuilder: (_) =>
                        FirstPageErrorIndicator(
                      onTryAgain: () => _pagingController.refresh(),
                    ),
                    newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                      onTap: () => _pagingController.retryLastFailedRequest(),
                    ),
                    noItemsFoundIndicatorBuilder: (_) =>
                        const NoItemsFoundIndicator(),
                  ));
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
