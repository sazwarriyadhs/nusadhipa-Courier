import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('NAVIGASI RUTE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: bgDark,
      ),
      body: Column(
        children: [
          // Peta
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: surfaceLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  // TRIK OSM DARK MODE: Invert warna dan putar hue
                  colorFilter: const ColorFilter.matrix(<double>[
                    -0.2126, -0.7152, -0.0722, 0, 255, // Red
                    -0.2126, -0.7152, -0.0722, 0, 255, // Green
                    -0.2126, -0.7152, -0.0722, 0, 255, // Blue
                    0,       0,       0,       1, 0,   // Alpha
                  ]),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(-6.2088, 106.8456), // Jakarta
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        // Pakai OSM Resmi (Gratis, Tanpa API Key)
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.nusadhipa.courier',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: const LatLng(-6.2088, 106.8456),
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: brandRed, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Tombol Action di bawah peta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text('BUKA NAVIGASI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courierBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.update, color: Colors.white),
                    label: const Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
