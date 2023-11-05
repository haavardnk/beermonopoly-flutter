class Release {
  Release({
    required this.name,
    this.releaseDate,
    this.beerCount,
    required this.productSelections,
  });

  factory Release.fromJson(Map<String, dynamic> release) => Release(
        name: release['name'],
        releaseDate: release['release_date'] != null
            ? DateTime.parse(release['release_date'].split("+")[0])
            : null,
        beerCount: release['beer_count'] ?? null,
        productSelections: [...release['product_selections']],
      );

  String name;
  DateTime? releaseDate;
  int? beerCount;
  List<String> productSelections;
}
