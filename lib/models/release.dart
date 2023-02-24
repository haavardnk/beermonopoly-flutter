class Release {
  Release({
    required this.name,
    this.releaseDate,
    this.beerCount,
    this.productSelection,
  });

  factory Release.fromJson(Map<String, dynamic> release) => Release(
        name: release['name'],
        releaseDate: release['release_date'] != null
            ? DateTime.parse(release['release_date'].split("+")[0])
            : null,
        beerCount: release['beer_count'] ?? null,
        productSelection: release['product_selection'] ?? null,
      );

  String name;
  DateTime? releaseDate;
  int? beerCount;
  String? productSelection;
}
