import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const GeoFenceApp());
}

class GeoFenceApp extends StatelessWidget {
  const GeoFenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GeoFenceHomePage(),
    );
  }
}

class GeoFenceHomePage extends StatefulWidget {
  const GeoFenceHomePage({super.key});

  @override
  _GeoFenceHomePageState createState() => _GeoFenceHomePageState();
}

class _GeoFenceHomePageState extends State<GeoFenceHomePage> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _accuracyController = TextEditingController();
  String result = "";

  Future<void> checkLocation() async {
    double latitude = double.tryParse(_latController.text) ?? 0.0;
    double longitude = double.tryParse(_lonController.text) ?? 0.0;
    double accuracy = double.tryParse(_accuracyController.text) ?? 0.0;

    bool isInside = await isLocationWithinArea(latitude, longitude, accuracy);
    setState(() {
      result = isInside ? "Inside Geofence" : "Outside Geofence";
    });
  }

  Future<bool> isLocationWithinArea(double lat, double lon, double accuracy) async {

    Map<String, dynamic> jsonData = jsonDecode('''{
  "results": {
    "type": "way",
    "id": 3996497,
    "bounds": {
      "minlat": 50.8364603,
      "minlon": -0.1510933,
      "maxlat": 50.8440534,
      "maxlon": -0.1427949
    },
    "geometry": [
      [
        {
          "lat": 50.8404969,
          "lon": -0.1504184
        },
        {
          "lat": 50.8400879,
          "lon": -0.1499697
        },
        {
          "lat": 50.8397147,
          "lon": -0.149544
        },
        {
          "lat": 50.8395274,
          "lon": -0.149197
        },
        {
          "lat": 50.8391651,
          "lon": -0.1484959
        },
        {
          "lat": 50.8390762,
          "lon": -0.1483239
        },
        {
          "lat": 50.8384232,
          "lon": -0.1471598
        },
        {
          "lat": 50.8380022,
          "lon": -0.1463473
        },
        {
          "lat": 50.837404,
          "lon": -0.1452608
        },
        {
          "lat": 50.8366421,
          "lon": -0.1438767
        },
        {
          "lat": 50.8365324,
          "lon": -0.143661
        },
        {
          "lat": 50.8364603,
          "lon": -0.1435131
        },
        {
          "lat": 50.8364653,
          "lon": -0.1433272
        },
        {
          "lat": 50.8365378,
          "lon": -0.142962
        },
        {
          "lat": 50.836581,
          "lon": -0.1428312
        },
        {
          "lat": 50.8367978,
          "lon": -0.1427949
        },
        {
          "lat": 50.8376857,
          "lon": -0.1429831
        },
        {
          "lat": 50.8386696,
          "lon": -0.1432138
        },
        {
          "lat": 50.8413691,
          "lon": -0.1444104
        },
        {
          "lat": 50.8440534,
          "lon": -0.1456728
        },
        {
          "lat": 50.8440443,
          "lon": -0.145926
        },
        {
          "lat": 50.8439954,
          "lon": -0.1469245
        },
        {
          "lat": 50.8437566,
          "lon": -0.1483785
        },
        {
          "lat": 50.8436649,
          "lon": -0.1487061
        },
        {
          "lat": 50.8428719,
          "lon": -0.1483598
        },
        {
          "lat": 50.8424651,
          "lon": -0.1481685
        },
        {
          "lat": 50.8423318,
          "lon": -0.1485973
        },
        {
          "lat": 50.8419149,
          "lon": -0.1489308
        },
        {
          "lat": 50.8420108,
          "lon": -0.1491414
        },
        {
          "lat": 50.841986,
          "lon": -0.1493002
        },
        {
          "lat": 50.8420274,
          "lon": -0.1493182
        },
        {
          "lat": 50.8420094,
          "lon": -0.1494606
        },
        {
          "lat": 50.8419646,
          "lon": -0.1494901
        },
        {
          "lat": 50.8419488,
          "lon": -0.1495438
        },
        {
          "lat": 50.8419538,
          "lon": -0.1496013
        },
        {
          "lat": 50.841985,
          "lon": -0.1496454
        },
        {
          "lat": 50.8419149,
          "lon": -0.1502386
        },
        {
          "lat": 50.8418668,
          "lon": -0.1504934
        },
        {
          "lat": 50.8417828,
          "lon": -0.1510933
        },
        {
          "lat": 50.8414955,
          "lon": -0.1510378
        },
        {
          "lat": 50.8414212,
          "lon": -0.1510021
        },
        {
          "lat": 50.8408752,
          "lon": -0.1506862
        },
        {
          "lat": 50.8404969,
          "lon": -0.1504184
        }
      ]
    ],
    "tags": {
      "name": "Park"
    }
    
  }
}''');
    List<dynamic> coordinates = jsonData['results']['geometry'][0];

    List<LatLng> polygon = coordinates
        .map((point) => LatLng(point['lat'], point['lon']))
        .toList();

    bool inside = isPointInPolygon(LatLng(lat, lon), polygon);
    if (inside) return true;

    for (LatLng point in polygon) {
      double distance = Geolocator.distanceBetween(lat, lon, point.latitude, point.longitude);
      if (distance <= accuracy) {
        return true;
      }
    }

    return false;
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng p1 = polygon[j];
      LatLng p2 = polygon[j + 1];

      if (((p1.longitude > point.longitude) != (p2.longitude > point.longitude)) &&
          (point.latitude <
              (p2.latitude - p1.latitude) * (point.longitude - p1.longitude) / (p2.longitude - p1.longitude) +
                  p1.latitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geo-Fence Checker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _lonController,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _accuracyController,
              decoration: const InputDecoration(labelText: "Accuracy (meters)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkLocation,
              child: const Text("Check Location"),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}
