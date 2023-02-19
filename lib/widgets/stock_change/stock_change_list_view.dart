import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import './stock_change_item.dart';
import '../../helpers/api_helper.dart';
import '../../models/stock_change.dart';
import '../../providers/filter.dart';
import '../../providers/auth.dart';
import '../products/pagination_indicators/first_page_error_indicator.dart';
import '../products/pagination_indicators/new_page_error_indicator.dart';
import '../products/pagination_indicators/no_items_found_indicator.dart';

class StockChangeListView extends StatefulWidget {
  const StockChangeListView({Key? key}) : super(key: key);

  @override
  _StockChangeListViewState createState() => _StockChangeListViewState();
}

class _StockChangeListViewState extends State<StockChangeListView> {
  late int _pageSize;
  late DateTime lastDate;
  final PagingController<int, StockChange> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 5);

  Future<void> _fetchPage(int pageKey, Filter filters, Auth auth) async {
    try {
      final newItems = await ApiHelper.getStockChangeList(
          pageKey, auth, _pageSize, filters.stockChangeStoreId);
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
    if (!_pagingController.hasListeners)
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
              ? PagedListView<int, StockChange>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<StockChange>(
                    animateTransitions: true,
                    transitionDuration: const Duration(milliseconds: 300),
                    itemBuilder: (context, item, index) {
                      if (index == 0) {
                        return StockChangeItem(stockChange: item);
                      } else {
                        return StockChangeItem(
                          stockChange: item,
                          lastDate: _pagingController
                              .itemList![index - 1].stock_unstock_at,
                        );
                      }
                    },
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
                )
              : PagedGridView<int, StockChange>(
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
                  builderDelegate: PagedChildBuilderDelegate<StockChange>(
                    animateTransitions: true,
                    transitionDuration: const Duration(milliseconds: 300),
                    itemBuilder: (context, item, index) =>
                        StockChangeItem(stockChange: item),
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
