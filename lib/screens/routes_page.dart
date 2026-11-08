import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);
  bool _isLoadingLocation = true;
  String? _locationError;
  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diblokir permanen. Buka Settings > App > Permissions');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentPosition, _currentZoom);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_currentPosition.latitude},${_currentPosition.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _updateStatus() {
    _getCurrentLocation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi berhasil diperbarui'),
        backgroundColor: courierGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'NAVIGASI RUTE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: bgDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: brandRed),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Error
          if (_locationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: brandRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: brandRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: brandRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: textPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Peta
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: surfaceLight),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: _currentZoom,
                        onPositionChanged: (position, hasGesture) {
                          setState(() => _currentZoom = position.zoom);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.nusadhipa.courier',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_on,
                                color: brandRed,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Card Info (ETA / Info Lokasi)
                Positioned(
                  top: 30,
                  left: 30,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceDark.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: surfaceLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: brandRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lokasi Saat Ini', style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(
                                '${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.gps_fixed, color: courierGreen, size: 16),
                      ],
                    ),
                  ),
                ),

                // Tombol Zoom In/Out
                Positioned(
                  right: 30,
                  bottom: 30,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() => _currentZoom += 1);
                          _mapController.move(_mapController.camera.center, _currentZoom);
                        },
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.remove,
                        onTap: () {
                          setState(() => _currentZoom -= 1);
                          _mapController.move(_mapController.camera.center, _currentZoom);
                        },
                      ),
                    ],
                  ),
                ),

                // Loading overlay
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: brandRed),
                    ),
                  ),
              ],
            ),
          ),

          // Tombol Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'BUKA NAVIGASI',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courierBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _updateStatus,
                    icon: const Icon(Icons.update, color: Colors.white),
                    label: const Text(
                      'UPDATE STATUS',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      foregroundColor: Colors.white,
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

// Widget tombol zoom custom
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: surfaceLight),
        ),
        child: Icon(icon, color: textPrimary, size: 24),
      ),
    );
  }
}

