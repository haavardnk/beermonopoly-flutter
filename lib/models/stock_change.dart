import './product.dart';

class StockChange {
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
            ? DateTime.parse(stockChange['stocked_at'])
            : null,
        unstocked_at: stockChange['unstocked_at'] != null
            ? DateTime.parse(stockChange['unstocked_at'])
            : null,
        product: Product.fromJson(stockChange['beer']),
        stock_unstock_at:
            stockChange['quantity'] > 0 && stockChange['stocked_at'] != null
                ? DateTime.parse(stockChange['stocked_at'])
                : stockChange['unstocked_at'] != null
                    ? DateTime.parse(stockChange['unstocked_at'])
                    : null,
      );

  String store;
  int quantity;
  DateTime stock_updated;
  DateTime? stocked_at;
  DateTime? unstocked_at;
  DateTime? stock_unstock_at;
  Product product;
}
