class MarketplaceProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice; // non-null = has a discount
  final double rating;
  final int reviewCount;
  final String icon;
  final String description;
  final String redirectUrl; // primary buy URL
  final String source; // "flipkart", "amazon", "indiamart", etc.
  final bool isCheapest; // cheapest option in its product group
  final List<String> tags; // e.g. ['Bestseller', 'Beginner', 'Organic']
  // Alternative buy links: {'Amazon': 'https://...', 'Flipkart': 'https://...'}
  final Map<String, String> alternatives;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.icon,
    required this.description,
    required this.redirectUrl,
    required this.source,
    this.isCheapest = false,
    this.tags = const [],
    this.alternatives = const {},
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  bool get hasDiscount => discountPercent > 0;
}
