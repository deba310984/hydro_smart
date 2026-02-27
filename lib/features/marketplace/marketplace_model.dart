class MarketplaceProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final String icon;
  final String description;
  final String
      redirectUrl; // URL to redirect to (Flipkart, Amazon, Distributor, etc.)
  final String source; // "flipkart", "amazon", "distributor", etc.

  MarketplaceProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.icon,
    required this.description,
    required this.redirectUrl,
    required this.source,
  });
}
