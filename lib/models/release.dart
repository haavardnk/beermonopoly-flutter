class Release {
  Release({
    required this.name,
    this.release_date,
    this.beer_count,
    this.product_selection,
  });

  factory Release.fromJson(Map<String, dynamic> release) => Release(
        name: release['name'],
        release_date: release['release_date'] != null
            ? DateTime.parse(release['release_date'])
            : null,
        beer_count: release['beer_count'] ?? null,
        product_selection: release['product_selection'] ?? null,
      );

  String name;
  DateTime? release_date;
  int? beer_count;
  String? product_selection;
}
