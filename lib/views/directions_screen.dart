import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/product_model.dart';

class DirectionsScreen extends StatelessWidget {
  final Product product;

  const DirectionsScreen({super.key, required this.product});

  Future<Position> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showErrorDialog(context, 'Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _showErrorDialog(context, 'Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showErrorDialog(
          context, 'Location permissions are permanently denied.');
      return Future.error(
          'Location permissions are permanently denied. Cannot access location.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<LatLng>> _getRoute(BuildContext context, double startLat,
      double startLng, double endLat, double endLng) async {
    final apiKey = "AIzaSyAsi3XSvcad47GTmV4vJh_novoRVzqEGGQ";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final points = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      } else {
        await _showErrorDialog(
            context, 'Failed to get directions: ${data['status']}');
        return Future.error('Failed to get directions: ${data['status']}');
      }
    } else {
      await _showErrorDialog(context, 'Failed to load directions.');
      return Future.error('Failed to load directions.');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return coordinates;
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Directions'),
          leading: BackButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                print('Nothing to pop');
              }
            },
          ),
        ),
        body: FutureBuilder<Position>(
          future: _getCurrentLocation(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final currentLocation = snapshot.data!;
            final productLocation =
                LatLng(product.coordinates[0], product.coordinates[1]);
            final userLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);

            return FutureBuilder<List<LatLng>>(
              future: _getRoute(
                context,
                userLocation.latitude,
                userLocation.longitude,
                productLocation.latitude,
                productLocation.longitude,
              ),
              builder: (context, routeSnapshot) {
                if (routeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (routeSnapshot.hasError) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: userLocation,
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('user'),
                        position: userLocation,
                        infoWindow: const InfoWindow(title: 'Your Location'),
                      ),
                      Marker(
                        markerId: const MarkerId('product'),
                        position: productLocation,
                        infoWindow: InfoWindow(title: product.title),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('dotted_route'),
                        points: [userLocation, productLocation],
                        color: Colors.red,
                        width: 3,
                        patterns: [
                          PatternItem.dash(10),
                          PatternItem.gap(10),
                        ],
                      ),
                    },
                  );
                }

                final route = routeSnapshot.data!;

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userLocation,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('user'),
                      position: userLocation,
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    ),
                    Marker(
                      markerId: const MarkerId('product'),
                      position: productLocation,
                      infoWindow: InfoWindow(title: product.title),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: route,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
