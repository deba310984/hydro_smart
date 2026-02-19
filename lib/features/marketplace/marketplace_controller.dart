import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'marketplace_model.dart';

final marketplaceProductsProvider = Provider<List<MarketplaceProduct>>((ref) {
  return [
    MarketplaceProduct(
      id: '1',
      name: 'Hydroponic Nutrient Solution 5L',
      category: 'Nutrients',
      price: 850,
      rating: 4.5,
      reviewCount: 124,
      icon: '🧪',
      description: 'Premium NPK solution for hydroponics',
    ),
    MarketplaceProduct(
      id: '2',
      name: 'pH Meter Digital',
      category: 'Monitoring',
      price: 1200,
      rating: 4.8,
      reviewCount: 89,
      icon: '📏',
      description: 'Accurate pH measurement device',
    ),
    MarketplaceProduct(
      id: '3',
      name: 'LED Grow Light 100W',
      category: 'Lighting',
      price: 3500,
      rating: 4.6,
      reviewCount: 156,
      icon: '💡',
      description: 'Full spectrum LED grow light',
    ),
    MarketplaceProduct(
      id: '4',
      name: 'Water Pump 3000L/h',
      category: 'Equipment',
      price: 2200,
      rating: 4.4,
      reviewCount: 92,
      icon: '💧',
      description: 'Submersible water pump',
    ),
    MarketplaceProduct(
      id: '5',
      name: 'Lettuce Seeds Pack',
      category: 'Seeds',
      price: 150,
      rating: 4.7,
      reviewCount: 234,
      icon: '🥬',
      description: 'Premium hydroponic lettuce seeds',
    ),
    MarketplaceProduct(
      id: '6',
      name: 'EC Meter TDS',
      category: 'Monitoring',
      price: 800,
      rating: 4.5,
      reviewCount: 67,
      icon: '📊',
      description: 'Electrical conductivity meter',
    ),
  ];
});
