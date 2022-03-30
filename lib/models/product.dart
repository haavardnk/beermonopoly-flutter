class Product {
  Product({
    required this.id,
    required this.name,
    required this.style,
    required this.price,
    required this.volume,
    this.pricePerVolume,
    this.stock,
    this.rating,
    this.checkins,
    this.abv,
    this.imageUrl,
    this.userRating,
    this.userWishlisted,
    this.vmpUrl,
    this.untappdUrl,
    this.untappdId,
  });

  factory Product.fromJson(Map<String, dynamic> product) => Product(
        id: product['vmp_id'],
        name: product['vmp_name'],
        style: product['style'] ??
            product['sub_category'] ??
            product['main_category'],
        stock: product['stock'],
        price: product['price'],
        volume: product['volume'],
        pricePerVolume: product['price_per_volume'],
        rating: product['rating'],
        checkins: product['checkins'],
        abv: product['abv'],
        imageUrl: product['label_sm_url'] != null &&
                product['label_sm_url'].contains('badge-beer-default.png')
            ? null
            : product['label_sm_url'],
        userRating: product['user_checked_in'] != null &&
                product['user_checked_in'].isNotEmpty
            ? product['user_checked_in'][0]['rating']
            : null,
        userWishlisted: product['user_wishlisted'] != null
            ? product['user_wishlisted']
            : false,
        vmpUrl: product['vmp_url'],
        untappdUrl: product['untpd_url'],
        untappdId: product['untpd_id'],
      );

  final int id;
  final String name;
  final String style;
  final double price;
  final double volume;
  final double? pricePerVolume;
  final int? stock;
  final double? rating;
  final int? checkins;
  final double? abv;
  final String? imageUrl;
  final double? userRating;
  final bool? userWishlisted;
  final String? vmpUrl;
  final String? untappdUrl;
  final int? untappdId;
}
