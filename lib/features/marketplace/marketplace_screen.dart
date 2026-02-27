import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'marketplace_controller.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String? selectedSource; // Filter by source
  String searchQuery = '';

  // Function to open URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Get the source display name and color
  String _getSourceLabel(String source) {
    switch (source.toLowerCase()) {
      case 'indiamart':
        return '🔴 IndiaMART';
      case 'flipkart':
        return '🟡 Flipkart';
      case 'amazon':
        return '🟠 Amazon';
      case 'meesho':
        return '💜 Meesho';
      case 'jiomart':
        return '🔵 JioMart';
      case 'olx':
        return '⚫ OLX';
      case 'distributor':
        return '🟢 Distributor';
      default:
        return source;
    }
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'indiamart':
        return Colors.red.shade700;
      case 'flipkart':
        return Colors.yellow.shade700;
      case 'amazon':
        return Colors.orange.shade700;
      case 'meesho':
        return Colors.purple.shade600;
      case 'jiomart':
        return Colors.blue.shade700;
      case 'olx':
        return Colors.grey.shade800;
      case 'distributor':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  bool _isCheapest(String productName) {
    return productName.contains('💰 CHEAPEST');
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(marketplaceProductsProvider);

    // Filter products based on source and search
    final filteredProducts = allProducts.where((product) {
      final matchesSource =
          selectedSource == null || product.source == selectedSource;
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSource && matchesSearch;
    }).toList();

    // Get unique sources
    final uniqueSources = allProducts.map((p) => p.source).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🛒 Hydroponic Marketplace',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '� Direct IndiaMART B2B Wholesale Pricing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${filteredProducts.length} Products • ${selectedSource != null ? _getSourceLabel(selectedSource!).split(' ')[1] : "All Sources"}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),

            // Source Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "All Sources" chip
                    FilterChip(
                      label: const Text('All Sources'),
                      selected: selectedSource == null,
                      onSelected: (_) {
                        setState(() => selectedSource = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    // Source chips
                    ...uniqueSources.map((source) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getSourceLabel(source)),
                          selected: selectedSource == source,
                          onSelected: (_) {
                            setState(() => selectedSource = source);
                          },
                          backgroundColor:
                              _getSourceColor(source).withOpacity(0.2),
                          selectedColor: _getSourceColor(source),
                          labelStyle: TextStyle(
                            color: selectedSource == source
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Products Grid
            if (filteredProducts.isNotEmpty)
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final isCheapest = _isCheapest(product.name);

                  return Card(
                    elevation: isCheapest ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isCheapest
                          ? BorderSide(
                              color: Colors.red.shade400,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cheapest Badge
                        if (isCheapest)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '💰 CHEAPEST OPTION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Product Image Container
                        Container(
                          height: isCheapest ? 80 : 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: isCheapest
                                ? BorderRadius.zero
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              product.icon,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),

                        // Product Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Source Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSourceColor(product.source),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    _getSourceLabel(product.source),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Product Name
                                Text(
                                  product.name
                                      .replaceAll('💰 CHEAPEST', '')
                                      .trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),

                                // Category
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 11,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${product.rating}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      ' (${product.reviewCount})',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Price and Buy Button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${product.price}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCheapest
                                                ? Colors.red.shade600
                                                : Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _launchUrl(product.redirectUrl);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart,
                                              size: 11,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Buy',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters or search query',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Footer Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Marketplace Tips',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 💰 Look for "CHEAPEST OPTION" badges to save money\n'
                    '• 🔍 Filter by platform to compare prices across retailers\n'
                    '• ✅ Check ratings before purchasing\n'
                    '• 🏪 OLX has used equipment at lower prices',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
