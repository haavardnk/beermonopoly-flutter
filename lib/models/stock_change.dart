import 'package:equatable/equatable.dart';

import './product.dart';

class StockChange extends Equatable {
  StockChange({
    required this.store,
    required this.quantity,
    required this.stock_updated,
    this.stocked_at,
    this.unstocked_at,
    this.stock_unstock_at,
    required this.product,
  });

  factory StockChange.fromJson(Map<String, dynamic> stockChange) => StockChange(
        store: stockChange['store'].toString(),
        quantity: stockChange['quantity'],
        stock_updated: DateTime.parse(stockChange['stock_updated']),
        stocked_at: stockChange['stocked_at'] != null
            ? DateTime.parse(stockChange['stocked_at'].split("+")[0])
            : null,
        unstocked_at: stockChange['unstocked_at'] != null
            ? DateTime.parse(stockChange['unstocked_at'].split("+")[0])
            : null,
        product: Product.fromJson(stockChange['beer']),
        stock_unstock_at:
            stockChange['quantity'] > 0 && stockChange['stocked_at'] != null
                ? DateTime.parse(stockChange['stocked_at'].split("+")[0])
                : stockChange['unstocked_at'] != null
                    ? DateTime.parse(stockChange['unstocked_at'].split("+")[0])
                    : null,
      );

  @override
  List<Object?> get props => [
        store,
        quantity,
        stock_updated,
        stocked_at,
        unstocked_at,
        stock_unstock_at,
        product,
      ];

  final String store;
  final int quantity;
  final DateTime stock_updated;
  final DateTime? stocked_at;
  final DateTime? unstocked_at;
  final DateTime? stock_unstock_at;
  final Product product;
}
