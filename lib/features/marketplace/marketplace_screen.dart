import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'marketplace_controller.dart';
import 'marketplace_model.dart';

//  View mode

enum _ViewMode { grid, list }

enum _SortMode { priceAsc, priceDesc, ratingDesc, reviewsDesc }

enum _BudgetFilter { all, budget, midRange, premium }

//  Constants

const _categories = [
  'All',
  'Nutrients',
  'Monitoring',
  'Lighting',
  'Equipment',
  'Seeds',
  'Growing Media',
  'Systems & Kits',
  'Maintenance',
];

const _platformIcons = {
  'amazon': '\u{1F7E0}',
  'flipkart': '\u{1F7E1}',
  'meesho': '\u{1F49C}',
  'jiomart': '\u{1F535}',
  'indiamart': '\u{1F534}',
  'olx': '\u26AB',
};

const _platformColors = {
  'amazon': Color(0xFFFF6600),
  'flipkart': Color(0xFF2874F0),
  'meesho': Color(0xFF9C27B0),
  'jiomart': Color(0xFF0070C0),
  'indiamart': Color(0xFFCC0000),
  'olx': Color(0xFF4A4A4A),
};

//  Main screen

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _ViewMode _viewMode = _ViewMode.grid;
  _SortMode _sortMode = _SortMode.priceAsc;
  _BudgetFilter _budgetFilter = _BudgetFilter.all;
  String? _selectedSource;
  String _searchQuery = '';
  bool _cheapestOnly = false;
  bool _searchActive = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  //  Filtering / sorting

  List<MarketplaceProduct> _filtered(List<MarketplaceProduct> all) {
    final category = _categories[_tabController.index];
    return all.where((p) {
      if (category != 'All' && p.category != category) return false;
      if (_selectedSource != null && p.source != _selectedSource) return false;
      if (_cheapestOnly && !p.isCheapest) return false;
      if (_budgetFilter == _BudgetFilter.budget && p.price > 999) return false;
      if (_budgetFilter == _BudgetFilter.midRange &&
          (p.price <= 999 || p.price > 5000)) return false;
      if (_budgetFilter == _BudgetFilter.premium && p.price <= 5000)
        return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.category.toLowerCase().contains(q) &&
            !p.description.toLowerCase().contains(q) &&
            !p.tags.any((t) => t.toLowerCase().contains(q))) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortMode) {
          case _SortMode.priceAsc:
            return a.price.compareTo(b.price);
          case _SortMode.priceDesc:
            return b.price.compareTo(a.price);
          case _SortMode.ratingDesc:
            return b.rating.compareTo(a.rating);
          case _SortMode.reviewsDesc:
            return b.reviewCount.compareTo(a.reviewCount);
        }
      });
  }

  Future<void> _launch(String url) async {
    if (url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  String _platformLabel(String source) {
    final icon = _platformIcons[source.toLowerCase()] ?? '\u{1F6D2}';
    final name = source[0].toUpperCase() + source.substring(1);
    return '$icon $name';
  }

  Color _platformColor(String source) =>
      _platformColors[source.toLowerCase()] ?? Colors.green;

  String _sortLabel(_SortMode m) {
    switch (m) {
      case _SortMode.priceAsc:
        return '\u{1F4B0} Price: Low \u2192 High';
      case _SortMode.priceDesc:
        return '\u{1F4B8} Price: High \u2192 Low';
      case _SortMode.ratingDesc:
        return '\u2B50 Best Rated';
      case _SortMode.reviewsDesc:
        return '\u{1F525} Most Reviews';
    }
  }

  void _showProductDetail(MarketplaceProduct p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(
        product: p,
        onLaunch: _launch,
        platformLabel: _platformLabel,
        platformColor: _platformColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(marketplaceProductsProvider);
    final filtered = _filtered(all);
    final uniqueSources = all.map((p) => p.source).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(filtered.length, all.length),
      body: Column(
        children: [
          _buildCategoryTabs(),
          _buildFilterRow(uniqueSources),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : _viewMode == _ViewMode.grid
                    ? _buildGrid(filtered)
                    : _buildList(filtered),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int shown, int total) {
    return AppBar(
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      elevation: 0,
      title: _searchActive
          ? TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hydroponic Store',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('$shown of $total products',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(_searchActive ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _searchActive = !_searchActive;
            if (!_searchActive) {
              _searchQuery = '';
              _searchCtrl.clear();
            }
          }),
        ),
        PopupMenuButton<_SortMode>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort',
          onSelected: (m) => setState(() => _sortMode = m),
          itemBuilder: (_) => _SortMode.values
              .map((m) => PopupMenuItem(
                    value: m,
                    child: Row(children: [
                      if (_sortMode == m)
                        const Icon(Icons.check, size: 16, color: Colors.green)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(_sortLabel(m)),
                    ]),
                  ))
              .toList(),
        ),
        IconButton(
          icon: Icon(
              _viewMode == _ViewMode.grid ? Icons.view_list : Icons.grid_view),
          tooltip: _viewMode == _ViewMode.grid ? 'List view' : 'Grid view',
          onPressed: () => setState(() => _viewMode =
              _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.green[700],
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: _categories.map((c) => Tab(text: c, height: 40)).toList(),
      ),
    );
  }

  Widget _buildFilterRow(List<String> sources) {
    final activeFilters = [
      if (_selectedSource != null) 1,
      if (_cheapestOnly) 1,
      if (_budgetFilter != _BudgetFilter.all) 1,
    ].length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip2(
                label: '\u{1F4B0} Cheapest Only',
                active: _cheapestOnly,
                onTap: () => setState(() => _cheapestOnly = !_cheapestOnly),
                activeColor: Colors.red[700]!,
              ),
              const SizedBox(width: 6),
              ...[
                (_BudgetFilter.budget, 'Under ₹999'),
                (_BudgetFilter.midRange, '₹1k–5k'),
                (_BudgetFilter.premium, '₹5k+'),
              ].map((t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip2(
                      label: t.$2,
                      active: _budgetFilter == t.$1,
                      onTap: () => setState(() => _budgetFilter =
                          _budgetFilter == t.$1 ? _BudgetFilter.all : t.$1),
                      activeColor: Colors.indigo,
                    ),
                  )),
              const SizedBox(width: 6),
              Container(width: 1, height: 22, color: Colors.grey[300]),
              const SizedBox(width: 6),
              _FilterChip2(
                label: 'All Platforms',
                active: _selectedSource == null,
                onTap: () => setState(() => _selectedSource = null),
                activeColor: Colors.green[700]!,
              ),
              ...sources.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _FilterChip2(
                      label: _platformLabel(s),
                      active: _selectedSource == s,
                      onTap: () => setState(() =>
                          _selectedSource = _selectedSource == s ? null : s),
                      activeColor: _platformColor(s),
                    ),
                  )),
            ]),
          ),
          if (activeFilters > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              Text(
                  '$activeFilters filter${activeFilters > 1 ? 's' : ''} active',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedSource = null;
                  _cheapestOnly = false;
                  _budgetFilter = _BudgetFilter.all;
                }),
                child: Text('Clear all',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No products found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Try adjusting your filters',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset Filters'),
              onPressed: () => setState(() {
                _selectedSource = null;
                _cheapestOnly = false;
                _budgetFilter = _BudgetFilter.all;
                _searchQuery = '';
                _searchCtrl.clear();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<MarketplaceProduct> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onTap: () => _showProductDetail(products[i]),
        onBuy: () => _launch(products[i].redirectUrl),
        platformLabel: _platformLabel,
        platformColor: _platformColor,
        isGrid: true,
      ),
    );
  }

  Widget _buildList(List<MarketplaceProduct> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onTap: () => _showProductDetail(products[i]),
        onBuy: () => _launch(products[i].redirectUrl),
        platformLabel: _platformLabel,
        platformColor: _platformColor,
        isGrid: false,
      ),
    );
  }
}

//  Reusable filter chip

class _FilterChip2 extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip2({
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? activeColor : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

//  Product card

class _ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onTap;
  final VoidCallback onBuy;
  final String Function(String) platformLabel;
  final Color Function(String) platformColor;
  final bool isGrid;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onBuy,
    required this.platformLabel,
    required this.platformColor,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid ? _gridCard(context) : _listCard(context);
  }

  Widget _gridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: product.isCheapest ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: product.isCheapest
              ? const BorderSide(color: Color(0xFFE53935), width: 2)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.isCheapest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Text('\u{1F4B0} CHEAPEST OPTION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            Container(
              height: product.isCheapest ? 72 : 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: product.isCheapest
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(children: [
                Center(
                    child: Text(product.icon,
                        style: const TextStyle(fontSize: 44))),
                if (product.hasDiscount)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('-${product.discountPercent.toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: platformColor(product.source),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(platformLabel(product.source),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 11.5)),
                    const SizedBox(height: 2),
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 3,
                        runSpacing: 2,
                        children: product.tags
                            .take(2)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(3),
                                    border:
                                        Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Text(tag,
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.green[800])),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, size: 10, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${product.rating}',
                          style: const TextStyle(fontSize: 10)),
                      Text(' (${product.reviewCount})',
                          style:
                              TextStyle(fontSize: 9, color: Colors.grey[500])),
                    ]),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount)
                                Text('₹${product.originalPrice!.toInt()}',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[500],
                                        decoration:
                                            TextDecoration.lineThrough)),
                              Text('₹${product.price.toInt()}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: product.isCheapest
                                          ? Colors.red[700]
                                          : Colors.green[700])),
                            ],
                          ),
                        ),
                        _BuyButton(onTap: onBuy, small: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: product.isCheapest
              ? const BorderSide(color: Color(0xFFE53935), width: 1.5)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text(product.icon,
                          style: const TextStyle(fontSize: 36))),
                ),
                if (product.isCheapest)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(8)),
                      ),
                      child: const Text('', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                if (product.hasDiscount)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6)),
                      ),
                      child: Text('-${product.discountPercent.toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: platformColor(product.source),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(platformLabel(product.source),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Text(product.category,
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ]),
                    const SizedBox(height: 4),
                    Text(product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      children: product.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Text(tag,
                                    style: TextStyle(
                                        fontSize: 9, color: Colors.green[800])),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text('${product.rating}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(' (${product.reviewCount} reviews)',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (product.hasDiscount)
                            Text('₹${product.originalPrice!.toInt()}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough)),
                          Text('₹${product.price.toInt()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: product.isCheapest
                                      ? Colors.red[700]
                                      : Colors.green[700])),
                        ],
                      ),
                      const SizedBox(width: 10),
                      _BuyButton(onTap: onBuy, small: false),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Buy button

class _BuyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool small;

  const _BuyButton({required this.onTap, required this.small});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 8 : 14, vertical: small ? 5 : 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shopping_cart_outlined,
              size: small ? 11 : 14, color: Colors.white),
          SizedBox(width: small ? 3 : 5),
          Text('Buy',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: small ? 10 : 12,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

//  Product detail bottom sheet

class _ProductDetailSheet extends StatelessWidget {
  final MarketplaceProduct product;
  final Future<void> Function(String) onLaunch;
  final String Function(String) platformLabel;
  final Color Function(String) platformColor;

  const _ProductDetailSheet({
    required this.product,
    required this.onLaunch,
    required this.platformLabel,
    required this.platformColor,
  });

  String _srcName(String source) =>
      source[0].toUpperCase() + source.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(product.icon,
                        style: const TextStyle(fontSize: 44))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: platformColor(product.source),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(platformLabel(product.source),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text(product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(product.category,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (product.hasDiscount)
                  Text('₹${product.originalPrice!.toInt()}',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough)),
                Text('₹${product.price.toInt()}',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: product.isCheapest
                            ? Colors.red[700]
                            : Colors.green[700])),
              ]),
              if (product.hasDiscount) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('${product.discountPercent.toInt()}% OFF',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
              if (product.isCheapest) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Text('\u{1F4B0} Cheapest',
                      style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
              const Spacer(),
              Row(children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 3),
                Text('${product.rating}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(' (${product.reviewCount})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
            ]),
            const SizedBox(height: 14),
            Text('About this product',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey[800])),
            const SizedBox(height: 6),
            Text(product.description,
                style: TextStyle(
                    color: Colors.grey[700], fontSize: 13, height: 1.5)),
            if (product.tags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: product.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: Text(
                    'Buy on ${_srcName(product.source)} — ₹${product.price.toInt()}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: platformColor(product.source),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () => onLaunch(product.redirectUrl),
              ),
            ),
            if (product.alternatives.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.compare_arrows,
                    size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text('Compare & Find Cheapest',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blueGrey[800])),
              ]),
              const SizedBox(height: 10),
              ...product.alternatives.entries.map((e) {
                final key = e.key.toLowerCase();
                final color = _platformColors[key] ?? Colors.blueGrey;
                final icon = _platformIcons[key] ?? '\u{1F6D2}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Text(icon, style: const TextStyle(fontSize: 16)),
                      label: Text('Search on ${e.key}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => onLaunch(e.value),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Text('\u{1F50D}', style: TextStyle(fontSize: 16)),
                label: const Text('Find cheapest on Google Shopping'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey[700],
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => onLaunch(
                    'https://www.google.com/search?q=${Uri.encodeComponent(product.name)}&tbm=shop'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
