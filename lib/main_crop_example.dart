import 'package:flutter/material.dart';
import 'features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart'; // Your existing dashboard

class HydroSmartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroSmart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: HomePage(),
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/crops': (context) => CropRecommendationPage(),
      },
    );
  }
}

/// Simple home page with navigation to crop panel
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HydroSmart'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Crop Recommendations Button
            ElevatedButton.icon(
              icon: Icon(Icons.grass, size: 28),
              label: Text(
                'Hydroponic Crops',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropRecommendationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

            SizedBox(height: 20),

            // Dashboard Button
            ElevatedButton.icon(
              icon: Icon(Icons.dashboard, size: 28),
              label: Text(
                'Dashboard',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

            SizedBox(height: 40),

            // Info Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌱 Crop Recommendation Panel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore 6 hydroponic crops with detailed information and advanced filtering by technique, season, duration, profit margin, difficulty, and market demand.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '✓ 6 sample crops with complete data\n'
                    '✓ 6 advanced filters\n'
                    '✓ Beautiful crop cards\n'
                    '✓ Real-time filtering\n'
                    '✓ Dark mode support',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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

// Alternative: If you want to add to existing dashboard
class DashboardWithCropButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: ListView(
        children: [
          // Your existing dashboard items...

          // Add this:
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.grass, color: Colors.green),
                title: Text('Hydroponic Crops'),
                subtitle: Text('View & filter available crops'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropRecommendationPage(),
                    ),
                  );
                },
              ),
            ),
          ),

          // ... rest of your dashboard
        ],
      ),
    );
  }
}
