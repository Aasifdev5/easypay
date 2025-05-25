import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPay',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const FuelStationApp(),
    );
  }
}

class FuelStationApp extends StatefulWidget {
  const FuelStationApp({super.key});

  @override
  State<FuelStationApp> createState() => _FuelStationAppState();
}

class _FuelStationAppState extends State<FuelStationApp> {
  int _currentScreen = 0;
  String? _selectedStation;
  String? _selectedAddress;

  final String _whatsappUrl = 'https://wa.me/+1234567890';
  final List<Map<String, String>> _stations = [
    {
      'name': 'ALEMANA - BIOPETROL',
      'address': 'AV. ALEMANA, 2DO ANILLO',
      'fuelTypes': 'ESPECIAL S2%  PREMIUM 0%',
      'vehicleCount': 'ALCANZA PARA 150 VEHÍCULOS',
      'lastUpdated': 'Última actualización: Sáb 12 Abr 13:46',
    },
    {
      'name': 'BENI - BIOPETROL',
      'address': 'AV. BENI, 2DO ANILLO',
      'fuelTypes': 'ESPECIAL S2%  PREMIUM 0%',
      'vehicleCount': 'ALCANZA PARA 150 VEHÍCULOS',
      'lastUpdated': 'Última actualización: Sáb 12 Abr 13:46',
    },
    {
      'name': '3 PASOS AL FRENTE',
      'address': 'CALLE D, CUARTO ANILLO',
      'fuelTypes': 'ESPECIAL S2%  PREMIUM 0%',
      'vehicleCount': 'ALCANZA PARA 150 VEHÍCULOS',
      'lastUpdated': 'Última actualización: Sáb 12 Abr 13:46',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentScreen,
        children: [
          _buildWelcomeScreen(context),
          _buildCityFilterScreen(context),
          _buildFuelTypeSelectionScreen(context),
          _buildStationListScreen(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: MediaQuery.of(context).size.height * 0.2,
            fit: BoxFit.contain,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Text(
            'Encuentra una ubicación cerca de tu ubicación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.036,
              color: const Color(0xFFFFCC00),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.82,
            height: MediaQuery.of(context).size.height * 0.057,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.031,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.041,
                  vertical: MediaQuery.of(context).size.height * 0.014,
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentScreen = 1;
                });
              },
              child: Text(
                'Ingresa con Gmail',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.041,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilterScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentScreen = 0;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.032,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height:
                    MediaQuery.of(context).size.height *
                    0.09, // Increased from 0.06
                width:
                    MediaQuery.of(context).size.width *
                    0.18, // Increased from 0.12
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [_buildChatButton(context)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.062,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.038),
              Text(
                'Encuentra una estación cerca',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.051,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
              Text(
                'Selecciona una ciudad',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.041,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: MediaQuery.of(context).size.width * 0.041,
                mainAxisSpacing: MediaQuery.of(context).size.height * 0.014,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCityCard('Santa Cruz', '27 surtidores', context),
                  _buildCityCard('La Paz', '10 surtidores', context),
                  _buildCityCard('Cochabamba', '21 surtidores', context),
                  _buildCityCard('El Alto', '12 surtidores', context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(String city, String dispensers, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentScreen = 2;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.41,
        height: MediaQuery.of(context).size.height * 0.104,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.031,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                city,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.041,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Text(
                dispensers,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.036,
                  color: const Color(0xFFFFC107),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelTypeSelectionScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentScreen = 1;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.032,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height:
                    MediaQuery.of(context).size.height *
                    0.09, // Increased from 0.06
                width:
                    MediaQuery.of(context).size.width *
                    0.18, // Increased from 0.12
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [_buildChatButton(context)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.062,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.038),
              Text(
                'Selecciona tipo de combustible',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.051,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: MediaQuery.of(context).size.width * 0.041,
                mainAxisSpacing: MediaQuery.of(context).size.height * 0.014,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFuelButton('Diesel', context),
                  _buildFuelButton('Gas', context),
                  _buildFuelButton('Gasolina', context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelButton(String fuelType, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentScreen = 3;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.385,
        height: MediaQuery.of(context).size.height * 0.076,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.031,
          ),
        ),
        child: Center(
          child: Text(
            fuelType,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.041,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFC107),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationListScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentScreen = 2;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.032,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height:
                    MediaQuery.of(context).size.height *
                    0.09, // Increased from 0.06
                width:
                    MediaQuery.of(context).size.width *
                    0.18, // Increased from 0.12
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [_buildChatButton(context)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.062,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.038),
              Card(
                color: const Color(0xFF1C1C1E),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ciudad',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.036,
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                          Text(
                            'Tipo de combustible',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.036,
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.014,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SANTA CRUZ',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.041,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'GASOLINA',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.041,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ],
                  ),
                ),
              ),
              ..._stations.map(
                (station) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStation = station['name'];
                      _selectedAddress = station['address'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  MapScreen(address: _selectedAddress!),
                        ),
                      );
                    });
                  },
                  child: _buildStationCard(
                    station['name']!,
                    station['address']!,
                    station['fuelTypes']!,
                    station['vehicleCount']!,
                    station['lastUpdated']!,
                    context,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(
    String stationName,
    String address,
    String fuelTypes,
    String vehicleCount,
    String lastUpdated,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.019,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.041,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.019),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stationName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.041,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                Icon(
                  _selectedStation == stationName
                      ? Icons.star
                      : Icons.star_border,
                  size: MediaQuery.of(context).size.width * 0.061,
                  color: const Color(0xFFFFC107),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.019),
            Text(
              address,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.036,
                color: const Color(0xFFA0A0A0),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fuelTypes.split('  ')[0],
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  fuelTypes.split('  ')[1],
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              vehicleCount,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.036,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFC107),
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              lastUpdated,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.031,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFA0A0A0),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton('Google', Icons.map, address, context),
                _buildNavigationButton(
                  'Waze',
                  Icons.directions,
                  address,
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    String label,
    IconData icon,
    String address,
    BuildContext context,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.359,
      height: MediaQuery.of(context).size.height * 0.057,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E2E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.031,
            ),
          ),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.014),
        ),
        onPressed: () => _launchNavigation(label, address),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.width * 0.061,
              color: const Color(0xFFFFC107),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.021),
            Text(
              label,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.036,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.01),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.075, // Increased from 0.05
        height:
            MediaQuery.of(context).size.height * 0.045, // Increased from 0.03
        child: InkWell(
          onTap: () => _launchWhatsApp(),
          child: Image.asset(
            'assets/images/whatsapp.png',
            height:
                MediaQuery.of(context).size.height *
                0.045, // Increased from 0.03
            width:
                MediaQuery.of(context).size.width *
                0.075, // Increased from 0.05
            color: Colors.white,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                color: Colors.white,
              ); // Fallback if image fails
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    if (await canLaunch(_whatsappUrl)) {
      await launch(_whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  Future<void> _launchNavigation(String app, String address) async {
    String url;
    if (app == 'Google') {
      url =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen(address: address)),
        );
      }
    } else {
      url =
          'https://www.waze.com/ul?query=${Uri.encodeComponent(address)}&navigate=yes';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch Waze')));
      }
    }
  }
}

class MapScreen extends StatefulWidget {
  final String address;

  const MapScreen({super.key, required this.address});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng _center;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    LatLng userLocation = const LatLng(-17.7833, -63.182);
    LatLng stationLocation;

    if (widget.address.contains('AV. ALEMANA')) {
      stationLocation = const LatLng(-17.7845, -63.183);
    } else if (widget.address.contains('AV. BENI')) {
      stationLocation = const LatLng(-17.785, -63.184);
    } else if (widget.address.contains('CALLE D')) {
      stationLocation = const LatLng(-17.7838, -63.1825);
    } else {
      stationLocation = userLocation;
    }
    _center = stationLocation;

    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('station'),
        position: stationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(title: widget.address),
      ),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          userLocation,
          LatLng(-17.7836, -63.1822),
          LatLng(-17.7837, -63.1824),
          stationLocation,
        ],
        color: Colors.purple,
        width: 5,
      ),
    );

    _getLocationFromAddress(widget.address);
  }

  void _getLocationFromAddress(String address) async {
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 14.0));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu ubicación → ${widget.address}'),
        backgroundColor: const Color(0xFF0D0D0D),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.032,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height:
                    MediaQuery.of(context).size.height *
                    0.09, // Increased from 0.06
                width:
                    MediaQuery.of(context).size.width *
                    0.18, // Increased from 0.12
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '4 min',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '1.7 km',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por Av. Adolfo Román Hijo, Av. Juan Pablo ...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mejor ruta, Tráfico habitual',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Salir más tarde'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ir ahora'),
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
  }
}
