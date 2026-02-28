import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'marketplace_model.dart';

// â”€â”€ Helper to build a Google Shopping search URL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
String _googleShop(String query) =>
    'https://www.google.com/search?q=${Uri.encodeComponent(query)}&tbm=shop';

String _amazon(String q) =>
    'https://www.amazon.in/s?k=${Uri.encodeComponent(q)}';
String _flipkart(String q) =>
    'https://www.flipkart.com/search?q=${Uri.encodeComponent(q)}';
String _meesho(String q) =>
    'https://www.meesho.com/search?q=${Uri.encodeComponent(q)}';
String _indiamart(String q) =>
    'https://dir.indiamart.com/search.mp?ss=${Uri.encodeComponent(q)}';
String _jiomart(String q) =>
    'https://www.jiomart.com/search/${Uri.encodeComponent(q)}';
String _olx(String q) =>
    'https://www.olx.in/items/q-${Uri.encodeComponent(q)}';

final marketplaceProductsProvider = Provider<List<MarketplaceProduct>>((ref) {
  return const [
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  NUTRIENTS & SOLUTIONS
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'nut_1',
      name: 'Basic NPK Nutrient Solution 5L',
      category: 'Nutrients',
      price: 420,
      originalPrice: 550,
      rating: 4.2,
      reviewCount: 112,
      icon: 'ðŸ§ª',
      description:
          'Budget-friendly NPK solution perfect for beginners. Well-balanced minerals for leafy greens and herbs.',
      redirectUrl:
          'https://www.meesho.com/search?q=npk+hydroponic+nutrient+solution',
      source: 'meesho',
      isCheapest: true,
      tags: ['Beginner', 'Budget', 'Leafy Greens'],
      alternatives: {
        'Amazon': 'https://www.amazon.in/s?k=npk+hydroponic+nutrient+solution',
        'Flipkart':
            'https://www.flipkart.com/search?q=npk+hydroponic+nutrient',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=hydroponic+nutrient+solution+npk',
        'Google Shopping':
            'https://www.google.com/search?q=npk+hydroponic+nutrient+solution+5L&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'nut_2',
      name: 'General Hydroponics MaxiGro 500g',
      category: 'Nutrients',
      price: 680,
      rating: 4.6,
      reviewCount: 198,
      icon: 'ðŸ§ª',
      description:
          'One-part grow formula with all essential macro and micro nutrients. Popular among intermediate growers.',
      redirectUrl:
          'https://www.amazon.in/s?k=general+hydroponics+maxigro',
      source: 'amazon',
      isCheapest: false,
      tags: ['Bestseller', 'Intermediate', 'All Crops'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=maxigro+hydroponic+nutrients',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=general+hydroponics+maxigro',
        'Google Shopping':
            'https://www.google.com/search?q=general+hydroponics+maxigro&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'nut_3',
      name: 'General Hydroponics Flora Series 3-Part',
      category: 'Nutrients',
      price: 1350,
      originalPrice: 1600,
      rating: 4.8,
      reviewCount: 342,
      icon: 'ðŸ§«',
      description:
          'The gold standard nutrient trilogy â€” FloraGro, FloraBloom, FloraMicro. Full control over every growth stage.',
      redirectUrl:
          'https://www.amazon.in/s?k=general+hydroponics+flora+series',
      source: 'amazon',
      isCheapest: false,
      tags: ['Premium', 'Professional', 'Best Rated'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=general+hydroponics+flora+series',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=flora+series+hydroponic',
        'Google Shopping':
            'https://www.google.com/search?q=general+hydroponics+flora+series+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'nut_4',
      name: 'Calcium Magnesium (CalMag) Supplement',
      category: 'Nutrients',
      price: 380,
      rating: 4.4,
      reviewCount: 87,
      icon: 'ðŸ’Š',
      description:
          'Prevents Ca/Mg deficiencies. Essential for tomatoes and peppers. Mix with base nutrients.',
      redirectUrl:
          'https://www.amazon.in/s?k=cal+mag+hydroponic+supplement',
      source: 'amazon',
      isCheapest: true,
      tags: ['Supplement', 'Tomatoes', 'Peppers'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=calcium+magnesium+hydroponic',
        'Meesho': 'https://www.meesho.com/search?q=calmag+plant+supplement',
        'Google Shopping':
            'https://www.google.com/search?q=cal+mag+supplement+hydroponics+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  MONITORING & TESTING
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'mon_1',
      name: 'Digital pH Meter Pocket',
      category: 'Monitoring',
      price: 349,
      originalPrice: 499,
      rating: 4.1,
      reviewCount: 215,
      icon: 'ðŸ“',
      description:
          'Compact pocket pH meter. Auto-calibration, waterproof tip, 0â€“14 pH range. Great starter tool.',
      redirectUrl:
          'https://www.meesho.com/search?q=digital+ph+meter+pocket',
      source: 'meesho',
      isCheapest: true,
      tags: ['Beginner', 'Budget', 'Compact'],
      alternatives: {
        'Amazon': 'https://www.amazon.in/s?k=pocket+ph+meter+digital',
        'Flipkart':
            'https://www.flipkart.com/search?q=digital+ph+meter+hydroponic',
        'OLX': 'https://www.olx.in/items/q-ph-meter',
        'Google Shopping':
            'https://www.google.com/search?q=pocket+ph+meter+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'mon_2',
      name: 'Bluelab pH Pen',
      category: 'Monitoring',
      price: 2800,
      rating: 4.9,
      reviewCount: 421,
      icon: 'ðŸ“',
      description:
          'Professional-grade pH pen from Bluelab. Trusted globally, Â±0.1 accuracy with HOLD function.',
      redirectUrl:
          'https://www.amazon.in/s?k=bluelab+ph+pen',
      source: 'amazon',
      isCheapest: false,
      tags: ['Professional', 'Best Rated', 'Precision'],
      alternatives: {
        'Flipkart': 'https://www.flipkart.com/search?q=bluelab+ph+pen',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=bluelab+ph+pen',
        'Google Shopping':
            'https://www.google.com/search?q=bluelab+ph+pen+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'mon_3',
      name: 'TDS / EC Meter Digital',
      category: 'Monitoring',
      price: 299,
      originalPrice: 450,
      rating: 4.3,
      reviewCount: 534,
      icon: 'ðŸ“Š',
      description:
          'Measures TDS, EC and temperature simultaneously. 0â€“9990 ppm range. Includes protective cap.',
      redirectUrl:
          'https://www.amazon.in/s?k=tds+ec+meter+digital+hydroponics',
      source: 'amazon',
      isCheapest: true,
      tags: ['Bestseller', 'Budget', 'Dual Meter'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=tds+ec+meter+digital',
        'Meesho': 'https://www.meesho.com/search?q=tds+meter+digital',
        'JioMart': 'https://www.jiomart.com/search/tds+meter',
        'Google Shopping':
            'https://www.google.com/search?q=tds+ec+meter+hydroponic+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'mon_4',
      name: 'Bluelab Combo Meter (pH + EC + Temp)',
      category: 'Monitoring',
      price: 8500,
      rating: 4.9,
      reviewCount: 267,
      icon: 'ðŸ”¬',
      description:
          'Single device measures pH, EC and temperature. Waterproof, LCD display. Industry benchmark.',
      redirectUrl:
          'https://www.amazon.in/s?k=bluelab+combo+meter',
      source: 'amazon',
      isCheapest: false,
      tags: ['Professional', 'All-in-One', 'Premium'],
      alternatives: {
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=bluelab+combo+meter',
        'Google Shopping':
            'https://www.google.com/search?q=bluelab+combo+meter+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'mon_5',
      name: 'Digital Thermometer & Hygrometer',
      category: 'Monitoring',
      price: 180,
      originalPrice: 250,
      rating: 4.2,
      reviewCount: 876,
      icon: 'ðŸŒ¡ï¸',
      description:
          'Temperature and humidity display with Min/Max memory. Perfect for monitoring grow room conditions.',
      redirectUrl:
          'https://www.amazon.in/s?k=digital+thermometer+hygrometer+grow+room',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'Budget', 'Bestseller'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=digital+thermometer+hygrometer',
        'Meesho':
            'https://www.meesho.com/search?q=thermometer+hygrometer+digital',
        'Google Shopping':
            'https://www.google.com/search?q=thermometer+hygrometer+grow+room+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  LIGHTING
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'light_1',
      name: 'LED Grow Light 45W Panel',
      category: 'Lighting',
      price: 899,
      originalPrice: 1299,
      rating: 4.1,
      reviewCount: 312,
      icon: 'ðŸ’¡',
      description:
          'Full spectrum LED panel with red/blue diodes. Covers 2Ã—2 ft canopy. Low heat output.',
      redirectUrl:
          'https://www.amazon.in/s?k=45w+led+grow+light+panel+full+spectrum',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Beginner', 'Full Spectrum'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=45w+led+grow+light+plant',
        'Meesho': 'https://www.meesho.com/search?q=led+grow+light+panel',
        'Google Shopping':
            'https://www.google.com/search?q=45w+led+grow+light+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'light_2',
      name: 'Mars Hydro TS 600W LED',
      category: 'Lighting',
      price: 3200,
      originalPrice: 3999,
      rating: 4.7,
      reviewCount: 654,
      icon: 'ðŸ’¡',
      description:
          'Samsung LM281B diodes, daisy chain capable, dimmable. Covers 2Ã—3 ft vegetative / 2Ã—2 ft flower.',
      redirectUrl:
          'https://www.amazon.in/s?k=mars+hydro+ts600+led+grow+light',
      source: 'amazon',
      isCheapest: false,
      tags: ['Bestseller', 'Intermediate', 'Dimmable'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=mars+hydro+ts600+grow+light',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=mars+hydro+led+grow+light',
        'Google Shopping':
            'https://www.google.com/search?q=mars+hydro+ts600+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'light_3',
      name: 'Spider Farmer SE5000 LED Bar',
      category: 'Lighting',
      price: 14500,
      rating: 4.9,
      reviewCount: 189,
      icon: 'ðŸŒŸ',
      description:
          'Commercial-grade 480W LED bar. 2.8 Âµmol/J efficacy, Samsung LM301H EVO chips. 5Ã—5 ft coverage.',
      redirectUrl:
          'https://www.amazon.in/s?k=spider+farmer+se5000+led+grow+light',
      source: 'amazon',
      isCheapest: false,
      tags: ['Professional', 'Commercial', 'High Efficiency'],
      alternatives: {
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=spider+farmer+led+grow+light',
        'Google Shopping':
            'https://www.google.com/search?q=spider+farmer+se5000+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'light_4',
      name: 'CFL T5 Fluorescent Grow Strip 2ft',
      category: 'Lighting',
      price: 450,
      rating: 3.9,
      reviewCount: 145,
      icon: 'ðŸ”¦',
      description:
          'T5 fluorescent tubes ideal for seedlings and cuttings. Low heat, low cost, easy to replace.',
      redirectUrl:
          'https://www.flipkart.com/search?q=t5+fluorescent+grow+light',
      source: 'flipkart',
      isCheapest: true,
      tags: ['Budget', 'Seedlings', 'Cuttings'],
      alternatives: {
        'Amazon':
            'https://www.amazon.in/s?k=t5+fluorescent+tube+grow+light',
        'Meesho':
            'https://www.meesho.com/search?q=t5+grow+light+fluorescent',
        'Google Shopping':
            'https://www.google.com/search?q=t5+fluorescent+grow+light+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  PUMPS & EQUIPMENT
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'equip_1',
      name: 'Submersible Water Pump 800L/h',
      category: 'Equipment',
      price: 450,
      originalPrice: 650,
      rating: 4.2,
      reviewCount: 478,
      icon: 'ðŸ’§',
      description:
          'Quiet submersible pump suitable for DWC and NFT systems. Max head 0.5m, 10W power.',
      redirectUrl:
          'https://www.amazon.in/s?k=submersible+water+pump+800lph+aquarium',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Beginner', 'DWC'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=submersible+water+pump+800lph',
        'Meesho':
            'https://www.meesho.com/search?q=submersible+pump+aquarium',
        'OLX': 'https://www.olx.in/items/q-submersible-water-pump',
        'Google Shopping':
            'https://www.google.com/search?q=submersible+pump+800lph+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'equip_2',
      name: 'Submersible Water Pump 3000L/h',
      category: 'Equipment',
      price: 1200,
      rating: 4.5,
      reviewCount: 312,
      icon: 'ðŸ’§',
      description:
          'Heavy-duty pump for large NFT or flood-and-drain systems. Max head 2m, 30W, durable impeller.',
      redirectUrl:
          'https://www.amazon.in/s?k=submersible+pump+3000lph+hydroponic',
      source: 'amazon',
      isCheapest: false,
      tags: ['Intermediate', 'NFT', 'High Flow'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=submersible+water+pump+3000lph',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=submersible+pump+3000+lph+hydroponics',
        'Google Shopping':
            'https://www.google.com/search?q=3000lph+submersible+pump+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'equip_3',
      name: 'Air Pump 4W Dual Outlet',
      category: 'Equipment',
      price: 280,
      originalPrice: 399,
      rating: 4.3,
      reviewCount: 623,
      icon: 'ðŸŒ¬ï¸',
      description:
          'Dual-outlet air pump with adjustable output. Ideal for DWC oxygenation. Very quiet operation.',
      redirectUrl:
          'https://www.amazon.in/s?k=aquarium+air+pump+4w+dual+outlet',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Bestseller', 'DWC'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=aquarium+air+pump+dual+outlet',
        'Meesho':
            'https://www.meesho.com/search?q=air+pump+aquarium+dual',
        'JioMart': 'https://www.jiomart.com/search/air+pump+aquarium',
        'Google Shopping':
            'https://www.google.com/search?q=4w+dual+outlet+air+pump+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'equip_4',
      name: 'Grow Tent 60Ã—60Ã—140cm',
      category: 'Equipment',
      price: 2199,
      originalPrice: 2999,
      rating: 4.4,
      reviewCount: 289,
      icon: 'â›º',
      description:
          '600D mylar-lined grow tent. Dual vent ports, thick metal poles. 60Ã—60Ã—140cm. Easy assembly.',
      redirectUrl:
          'https://www.amazon.in/s?k=grow+tent+60x60+hydroponics',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Mylar Lined', 'Easy Setup'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=grow+tent+60cm+plants',
        'Meesho':
            'https://www.meesho.com/search?q=grow+tent+60x60+indoor',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=grow+tent+60+cm',
        'Google Shopping':
            'https://www.google.com/search?q=grow+tent+60x60+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'equip_5',
      name: 'Inline Duct Fan 4 inch with Carbon Filter',
      category: 'Equipment',
      price: 1800,
      originalPrice: 2400,
      rating: 4.5,
      reviewCount: 198,
      icon: 'ðŸŒ€',
      description:
          'Complete ventilation kit: 4" inline fan + activated carbon filter + ducting. Silent motor.',
      redirectUrl:
          'https://www.amazon.in/s?k=4+inch+inline+duct+fan+carbon+filter',
      source: 'amazon',
      isCheapest: false,
      tags: ['Odour Control', 'Intermediate', 'Kit'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=inline+fan+carbon+filter+grow',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=inline+duct+fan+carbon+filter',
        'Google Shopping':
            'https://www.google.com/search?q=4+inch+inline+fan+carbon+filter+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'equip_6',
      name: 'Digital Timer Plug (24h Programmable)',
      category: 'Equipment',
      price: 199,
      originalPrice: 299,
      rating: 4.4,
      reviewCount: 1204,
      icon: 'â±ï¸',
      description:
          'Mechanical 24h plug-in timer with 15 min intervals. Automate lights and pumps easily.',
      redirectUrl:
          'https://www.amazon.in/s?k=24+hour+timer+plug+programmable',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'Budget', 'Bestseller', 'Automation'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=programmable+timer+switch+24+hour',
        'Meesho':
            'https://www.meesho.com/search?q=digital+timer+plug+switch',
        'JioMart': 'https://www.jiomart.com/search/timer+plug+switch',
        'Google Shopping':
            'https://www.google.com/search?q=24h+programmable+timer+plug+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  SEEDS
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'seed_1',
      name: 'Lettuce Butterhead Seeds (500 seeds)',
      category: 'Seeds',
      price: 79,
      rating: 4.5,
      reviewCount: 342,
      icon: 'ðŸ¥¬',
      description:
          'High-germination butterhead lettuce. Ready in 28â€“35 days in DWC or NFT. Non-GMO.',
      redirectUrl:
          'https://www.amazon.in/s?k=butterhead+lettuce+seeds+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'Fast Grow', 'Non-GMO'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=lettuce+seeds+hydroponic',
        'Meesho': 'https://www.meesho.com/search?q=lettuce+seeds+pack',
        'JioMart': 'https://www.jiomart.com/search/lettuce+seeds',
        'Google Shopping':
            'https://www.google.com/search?q=butterhead+lettuce+seeds+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'seed_2',
      name: 'Cherry Tomato Hybrid F1 Seeds',
      category: 'Seeds',
      price: 189,
      originalPrice: 249,
      rating: 4.6,
      reviewCount: 289,
      icon: 'ðŸ…',
      description:
          'Indeterminate hybrid variety. Clusters of sweet 15â€“20g fruits. Ideal for DWC and NFT.',
      redirectUrl:
          'https://www.amazon.in/s?k=cherry+tomato+f1+hybrid+seeds',
      source: 'amazon',
      isCheapest: true,
      tags: ['Hybrid', 'High Yield', 'Popular'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=cherry+tomato+hybrid+f1+seeds',
        'Meesho': 'https://www.meesho.com/search?q=cherry+tomato+seeds',
        'Google Shopping':
            'https://www.google.com/search?q=cherry+tomato+f1+seeds+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'seed_3',
      name: 'Basil Genovese Seeds (Organic)',
      category: 'Seeds',
      price: 99,
      rating: 4.7,
      reviewCount: 198,
      icon: 'ðŸŒ¿',
      description:
          'Classic Italian basil. Strong aroma, broad leaves. Ready in 21â€“27 days. USDA organic certified.',
      redirectUrl:
          'https://www.amazon.in/s?k=organic+basil+genovese+seeds',
      source: 'amazon',
      isCheapest: true,
      tags: ['Organic', 'Herbs', 'Fast Grow'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=basil+seeds+organic+genovese',
        'Meesho': 'https://www.meesho.com/search?q=basil+seeds+organic',
        'Google Shopping':
            'https://www.google.com/search?q=organic+genovese+basil+seeds+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'seed_4',
      name: 'Spinach Palak Seeds (250g)',
      category: 'Seeds',
      price: 129,
      rating: 4.3,
      reviewCount: 156,
      icon: 'ðŸƒ',
      description:
          'Smooth-leaf spinach variety for hydroponic systems. Rich in iron. 25â€“30 day turnaround.',
      redirectUrl:
          'https://www.amazon.in/s?k=palak+spinach+seeds+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Nutritious', 'Fast Grow', 'Beginner'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=spinach+palak+seeds',
        'Meesho': 'https://www.meesho.com/search?q=spinach+seeds+palak',
        'Google Shopping':
            'https://www.google.com/search?q=palak+spinach+seeds+hydroponic+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'seed_5',
      name: 'Strawberry Variety Seed Mix',
      category: 'Seeds',
      price: 249,
      originalPrice: 350,
      rating: 4.4,
      reviewCount: 178,
      icon: 'ðŸ“',
      description:
          'Mixed alpine and everbearing strawberry varieties. Ideal for vertical and tower systems.',
      redirectUrl:
          'https://www.amazon.in/s?k=strawberry+seeds+hydroponic+mix',
      source: 'amazon',
      isCheapest: false,
      tags: ['Premium', 'Fruits', 'Vertical Systems'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=strawberry+seeds+mix',
        'Google Shopping':
            'https://www.google.com/search?q=strawberry+seeds+hydroponic+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  GROWING MEDIA
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'media_1',
      name: 'Rockwool Grow Cubes 4Ã—4cm (Pack of 24)',
      category: 'Growing Media',
      price: 299,
      originalPrice: 399,
      rating: 4.3,
      reviewCount: 267,
      icon: 'ðŸª¨',
      description:
          'Pre-formed rockwool starter cubes. Pre-soak in pH 5.5 water for best germination results.',
      redirectUrl:
          'https://www.amazon.in/s?k=rockwool+grow+cubes+4x4+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'Germination', 'Seed Starting'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=rockwool+grow+cubes+hydroponic',
        'Meesho':
            'https://www.meesho.com/search?q=rockwool+cubes+plant',
        'JioMart': 'https://www.jiomart.com/search/rockwool+cubes',
        'Google Shopping':
            'https://www.google.com/search?q=rockwool+starter+cubes+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'media_2',
      name: 'Expanded Clay Pebbles (LECA) 10L',
      category: 'Growing Media',
      price: 399,
      originalPrice: 549,
      rating: 4.5,
      reviewCount: 432,
      icon: 'âšª',
      description:
          'Reusable, pH-neutral LECA balls. Excellent aeration and drainage. Suits DWC, ebb-and-flow.',
      redirectUrl:
          'https://www.amazon.in/s?k=expanded+clay+pebbles+leca+10+litre',
      source: 'amazon',
      isCheapest: true,
      tags: ['Bestseller', 'Reusable', 'DWC', 'Ebb & Flow'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=expanded+clay+pebbles+leca',
        'Meesho':
            'https://www.meesho.com/search?q=clay+pebbles+leca+hydroponics',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=expanded+clay+pebbles+hydroponics',
        'Google Shopping':
            'https://www.google.com/search?q=leca+expanded+clay+pebbles+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'media_3',
      name: 'Coco Coir Brick 650g (Makes 9L)',
      category: 'Growing Media',
      price: 89,
      rating: 4.4,
      reviewCount: 567,
      icon: 'ðŸ¥¥',
      description:
          'Compressed coco coir brick. Expands ~14x when hydrated. pH neutral, excellent moisture retention.',
      redirectUrl:
          'https://www.amazon.in/s?k=coco+coir+brick+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Bestseller', 'Organic'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=coco+coir+brick+hydroponic',
        'Meesho': 'https://www.meesho.com/search?q=coco+coir+brick',
        'JioMart': 'https://www.jiomart.com/search/coco+coir',
        'Google Shopping':
            'https://www.google.com/search?q=coco+coir+brick+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'media_4',
      name: 'Perlite Horticultural Grade 5L',
      category: 'Growing Media',
      price: 199,
      rating: 4.3,
      reviewCount: 312,
      icon: 'ðŸ”˜',
      description:
          'Coarse perlite for improved drainage when mixed with coco. Prevents root rot in media beds.',
      redirectUrl:
          'https://www.amazon.in/s?k=perlite+horticultural+grade+5+litre',
      source: 'amazon',
      isCheapest: true,
      tags: ['Budget', 'Root Health', 'Mix Media'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=perlite+horticultural+hydroponics',
        'Meesho': 'https://www.meesho.com/search?q=perlite+5+litre',
        'Google Shopping':
            'https://www.google.com/search?q=perlite+horticultural+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  SYSTEMS & KITS
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'sys_1',
      name: 'DWC Bucket Starter Kit 20L',
      category: 'Systems & Kits',
      price: 999,
      originalPrice: 1499,
      rating: 4.3,
      reviewCount: 187,
      icon: 'ðŸª£',
      description:
          'Complete DWC bucket kit: 20L food-safe bucket, net pots, air pump, stone, tubing. Great for beginners.',
      redirectUrl:
          'https://www.amazon.in/s?k=dwc+bucket+kit+hydroponics+starter',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'DIY', 'DWC', 'All Included'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=dwc+hydroponic+bucket+kit',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=dwc+hydroponics+kit',
        'Google Shopping':
            'https://www.google.com/search?q=dwc+bucket+hydroponic+kit+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'sys_2',
      name: 'NFT Pipe System 6-channel (1.2m)',
      category: 'Systems & Kits',
      price: 2800,
      originalPrice: 3500,
      rating: 4.6,
      reviewCount: 134,
      icon: 'ðŸ—ï¸',
      description:
          '6 channels, 1.2m long, 50mm NFT pipes with net cup holes. Includes pump, reservoir, timer.',
      redirectUrl:
          'https://www.amazon.in/s?k=nft+channel+hydroponic+system+6+channel',
      source: 'amazon',
      isCheapest: false,
      tags: ['Intermediate', 'Lettuce', 'NFT', 'Multi-channel'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=nft+hydroponics+6+channel+system',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=nft+hydroponic+system+channel',
        'Google Shopping':
            'https://www.google.com/search?q=NFT+hydroponic+6+channel+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'sys_3',
      name: 'Kratky Jar Kit (5 Plants)',
      category: 'Systems & Kits',
      price: 599,
      rating: 4.4,
      reviewCount: 456,
      icon: 'ðŸ«™',
      description:
          'Passive Kratky system â€” no pump needed. Five wide-mouth mason jars with net cup lids. Beginner dream.',
      redirectUrl:
          'https://www.amazon.in/s?k=kratky+method+jar+kit+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Beginner', 'No Pump', 'Indoor', 'Low Cost'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=kratky+hydroponic+jar+kit',
        'Meesho':
            'https://www.meesho.com/search?q=kratky+hydroponic+kit',
        'Google Shopping':
            'https://www.google.com/search?q=kratky+jar+kit+hydroponics+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'sys_4',
      name: 'Complete Hydroponics Starter Kit (Premium)',
      category: 'Systems & Kits',
      price: 7499,
      originalPrice: 9999,
      rating: 4.8,
      reviewCount: 512,
      icon: 'ðŸ“¦',
      description:
          'All-in-one kit: NFT system, pH/EC meters, nutrients, growing media, seeds, timer. Everything to start.',
      redirectUrl:
          'https://www.amazon.in/s?k=complete+hydroponic+starter+kit',
      source: 'amazon',
      isCheapest: false,
      tags: ['All Included', 'Premium', 'Best Rated', 'Gift'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=complete+hydroponic+starter+kit',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=hydroponic+starter+kit+complete',
        'Google Shopping':
            'https://www.google.com/search?q=complete+hydroponic+kit+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'sys_5',
      name: 'Vertical Tower Garden (5 Tier, 20 pods)',
      category: 'Systems & Kits',
      price: 3999,
      originalPrice: 5499,
      rating: 4.5,
      reviewCount: 278,
      icon: 'ðŸ—¼',
      description:
          '5-tier rotating tower with 20 planting pods. Built-in pump and reservoir. Ideal for strawberries & herbs.',
      redirectUrl:
          'https://www.amazon.in/s?k=vertical+tower+garden+hydroponic+20+pods',
      source: 'amazon',
      isCheapest: false,
      tags: ['Vertical', 'Fruits', 'Herbs', 'Space Saving'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=vertical+hydroponic+tower+garden',
        'IndiaMART':
            'https://dir.indiamart.com/search.mp?ss=vertical+tower+garden+hydroponic',
        'Google Shopping':
            'https://www.google.com/search?q=vertical+tower+garden+20+pod+india&tbm=shop',
      },
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  MAINTENANCE
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    MarketplaceProduct(
      id: 'maint_1',
      name: 'pH Up & Down Solution Set',
      category: 'Maintenance',
      price: 249,
      originalPrice: 349,
      rating: 4.5,
      reviewCount: 634,
      icon: 'âš—ï¸',
      description:
          'Phosphoric acid (pH Down) and Potassium hydroxide (pH Up). Highly concentrated â€” 1ml per 10L.',
      redirectUrl:
          'https://www.amazon.in/s?k=ph+up+down+solution+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Essential', 'Bestseller', 'Beginner'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=ph+up+down+hydroponic+solution',
        'Meesho':
            'https://www.meesho.com/search?q=ph+up+down+solution',
        'Google Shopping':
            'https://www.google.com/search?q=ph+up+down+solution+hydroponic+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'maint_2',
      name: 'Hydrogen Peroxide 3% (Root Flush)',
      category: 'Maintenance',
      price: 120,
      rating: 4.2,
      reviewCount: 312,
      icon: 'ðŸ§´',
      description:
          'Prevents root rot and kills pathogens. Use at 2â€“5 ml/L for system flush. Food-grade formula.',
      redirectUrl:
          'https://www.amazon.in/s?k=hydrogen+peroxide+3+percent+hydroponic',
      source: 'amazon',
      isCheapest: true,
      tags: ['Root Health', 'Budget', 'Preventive'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=hydrogen+peroxide+3+percent',
        'Meesho':
            'https://www.meesho.com/search?q=hydrogen+peroxide+3+percent',
        'Google Shopping':
            'https://www.google.com/search?q=hydrogen+peroxide+3+percent+hydroponic+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'maint_3',
      name: 'Beneficial Bacteria (Hydroguard)',
      category: 'Maintenance',
      price: 899,
      originalPrice: 1100,
      rating: 4.8,
      reviewCount: 245,
      icon: 'ðŸ¦ ',
      description:
          'Bacillus amyloliquefaciens root inoculant. Prevents pythium root rot, boosts nutrient uptake.',
      redirectUrl:
          'https://www.amazon.in/s?k=hydroguard+beneficial+bacteria+bacillus',
      source: 'amazon',
      isCheapest: false,
      tags: ['Root Health', 'Premium', 'Pythium Prevention'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=beneficial+bacteria+hydroponic+root',
        'Google Shopping':
            'https://www.google.com/search?q=hydroguard+bacillus+hydroponic+india&tbm=shop',
      },
    ),
    MarketplaceProduct(
      id: 'maint_4',
      name: 'Silica / Potassium Silicate Supplement',
      category: 'Maintenance',
      price: 399,
      rating: 4.4,
      reviewCount: 134,
      icon: 'ðŸ’Ž',
      description:
          'Strengthens cell walls, improves heat/drought tolerance. Add to reservoir throughout growth.',
      redirectUrl:
          'https://www.amazon.in/s?k=potassium+silicate+hydroponic',
      source: 'amazon',
      isCheapest: false,
      tags: ['Supplement', 'Stress Resistance', 'Intermediate'],
      alternatives: {
        'Flipkart':
            'https://www.flipkart.com/search?q=potassium+silicate+plant+supplement',
        'Google Shopping':
            'https://www.google.com/search?q=potassium+silicate+supplement+hydroponic+india&tbm=shop',
      },
    ),
  ];
});
