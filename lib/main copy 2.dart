import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: const Color(0xFFFFC107),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('https://easypay.lat/api/user'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FuelStationApp()),
            );
          }
        } else {
          await prefs.remove('auth_token');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.2,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'EasyPay',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFC107),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Correo electrónico y contraseña son obligatorios';
      });
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'No hay conexión a internet';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://easypay.lat/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token'] ?? '');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FuelStationApp()),
          );
        }
      } else {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        setState(() {
          _errorMessage = data['message'] ?? 'Error al iniciar sesión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.062,
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.18,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.email,
                  hintText: 'Correo electrónico *',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hintText: 'Contraseña *',
                  obscureText: true,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                      )
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            MediaQuery.of(context).size.height * 0.06,
                          ),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFFC107)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _whatsappController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Todos los campos son obligatorios';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(_whatsappController.text.trim())) {
      setState(() {
        _errorMessage = 'Ingresa un número de WhatsApp válido (10-15 dígitos)';
      });
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'No hay conexión a internet';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://easypay.lat/api/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'password_confirmation': _confirmPasswordController.text,
              'whatsapp_number': _whatsappController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token'] ?? '');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FuelStationApp()),
          );
        }
      } else {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        setState(() {
          _errorMessage = data['message'] ?? 'Error al registrarse';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.062,
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.18,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                _buildTextField(
                  controller: _nameController,
                  icon: Icons.person,
                  hintText: 'Nombre *',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.email,
                  hintText: 'Correo electrónico *',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hintText: 'Contraseña *',
                  obscureText: true,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock,
                  hintText: 'Confirmar Contraseña *',
                  obscureText: true,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(
                  controller: _whatsappController,
                  icon: Icons.phone,
                  hintText: 'Número de WhatsApp *',
                  keyboardType: TextInputType.phone,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                      )
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            MediaQuery.of(context).size.height * 0.06,
                          ),
                        ),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFFC107)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class Station {
  final String name;
  final String rawAddress;
  final String address;
  final String mainFuelType;
  final String displayFuelType;
  final String vehicleCount;
  final String lastUpdated;
  final String city;
  final double latitude;
  final double longitude;
  final double distance;

  Station({
    required this.name,
    required this.rawAddress,
    required this.address,
    required this.mainFuelType,
    required this.displayFuelType,
    required this.vehicleCount,
    required this.lastUpdated,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}

class AddressCache {
  static final Map<String, Map<String, dynamic>> _cache = {};

  static void store(String rawAddress, Map<String, dynamic> data) {
    _cache[rawAddress] = data;
  }

  static Map<String, dynamic>? retrieve(String rawAddress) {
    return _cache[rawAddress];
  }

  static bool contains(String rawAddress) {
    return _cache.containsKey(rawAddress);
  }
}

// Top-level function for isolate-safe JSON parsing
Map<String, dynamic> parseStations(String responseBody) {
  try {
    final data = jsonDecode(responseBody);
    if (data is! Map<String, dynamic>) {
      print('Error: Response is not a valid JSON object');
      return {'stations': <Station>[]};
    }

    List<Station> stations = [];
    if (data['estaciones'] != null && data['estaciones'] is List) {
      stations.addAll(parseStationsFromResponse(data['estaciones']));
    }
    return {'stations': stations};
  } on FormatException catch (e) {
    print('JSON parsing error: $e');
    return {'stations': <Station>[]};
  } catch (e) {
    print('Unexpected error parsing stations: $e');
    return {'stations': <Station>[]};
  }
}

List<Station> parseStationsFromResponse(List<dynamic> estaciones) {
  List<Station> stations = [];
  for (var stationEntry in estaciones) {
    if (stationEntry is Map) {
      stationEntry.forEach((stationName, details) {
        if (details is List && details.isNotEmpty) {
          var detail = details[0];
          if (detail is Map) {
            String rawAddress = detail['direccion']?.toString() ?? 'No address';
            rawAddress = rawAddress.replaceAll('Nu00BA', 'Nº');
            String city = detail['ciudad']?.split('-')[0].trim() ?? 'Unknown';
            String address = '$rawAddress, $city';
            double latitude = detail['latitud']?.toDouble() ?? 0.0;
            double longitude = detail['longitud']?.toDouble() ?? 0.0;
            double distance = detail['distancia']?.toDouble() ?? 0.0;

            List<dynamic> tanks =
                detail['tanques'] is List ? detail['tanques'] : [];
            for (var tank in tanks) {
              int nroproducto = tank['nroproductoanh'] ?? 0;
              double stock = (tank['stock'] ?? 0).toDouble();
              stock = stock < 0 ? 0 : stock;

              List<String> fuelTypes = normalizeFuelType(
                  tank['descripcion']?.toString().split(' - ').last ?? '',
                  nroproducto);
              if (fuelTypes.isEmpty) continue;

              String mainFuelType = fuelTypes[0];
              String displayFuelType = fuelTypes[1];
              String vehicleCount =
                  '$displayFuelType: ${stock.toStringAsFixed(2)} L';
              String lastUpdated = tank['ultimaactualizacion'] != null
                  ? 'Última actualización: ${tank['ultimaactualizacion']}'
                  : 'Última actualización: ${DateFormat('EEE dd MMM HH:mm').format(DateTime.now())}';

              stations.add(Station(
                name: stationName,
                rawAddress: rawAddress,
                address: address,
                mainFuelType: mainFuelType,
                displayFuelType: displayFuelType,
                vehicleCount: vehicleCount,
                lastUpdated: lastUpdated,
                city: city,
                latitude: latitude,
                longitude: longitude,
                distance: distance,
              ));
            }
          }
        }
      });
    }
  }
  return stations;
}

List<String> normalizeFuelType(String fuel, int nroproducto) {
  fuel = fuel.toLowerCase().trim();
  const fuelTypeMap = {
    1: ['Gasolina', 'G. Especial'],
    2: ['Diesel', 'Diesel'],
    3: ['Gasolina', 'G. Especial'],
    7: ['Gasolina', 'G. Especial+'],
    8: ['Gas', 'Gas'],
    10: ['Diesel', 'Diesel'],
  };

  if (fuel.contains('gnv') || fuel.contains('gas')) {
    return ['Gas', 'Gas'];
  } else if (fuel.contains('diesel')) {
    return ['Diesel', 'Diesel'];
  } else if (fuel.contains('gasolina')) {
    if (fuel.contains('especial+')) {
      return ['Gasolina', 'G. Especial+'];
    } else if (fuel.contains('especial')) {
      return ['Gasolina', 'G. Especial'];
    } else if (fuel.contains('premium') || fuel.contains('gp+')) {
      return ['Gasolina', 'PREMIUM'];
    } else if (fuel.contains('plus')) {
      return ['Gasolina', 'PLUS'];
    }
  }

  return fuelTypeMap[nroproducto] ?? ['Gasolina', 'G. Especial'];
}

class FuelStationApp extends StatefulWidget {
  const FuelStationApp({super.key});

  @override
  State<FuelStationApp> createState() => _FuelStationAppState();
}

class _FuelStationAppState extends State<FuelStationApp> {
  String? _selectedStation;
  String? _selectedCity;
  String _selectedFuelType = 'Diesel';
  List<Station> _stations = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentScreen = 0;
  DateTime? _lastFetchTime;
  final Map<String, List<Station>> _stationCache = {};
  final Map<int, int> _stationCountByCity = {};

  final List<Map<String, dynamic>> _cities = [
    {'code': 0, 'name': 'All Cities'},
    {'code': 1, 'name': 'Santa Cruz'},
    {'code': 2, 'name': 'Cochabamba'},
    {'code': 3, 'name': 'La Paz'},
    {'code': 4, 'name': 'Potosí'},
    {'code': 5, 'name': 'Oruro'},
    {'code': 6, 'name': 'Beni'},
    {'code': 7, 'name': 'Sucre'},
    {'code': 8, 'name': 'Tarija'},
    {'code': 9, 'name': 'Pando'},
  ];

  final String _apiUrl =
      'http://bo_baas_bcp_server.petroboxinc.com:8102/api/stock/getstockinfobyfuelid';
  final List<String> _fuelTypes = ['Diesel', 'Gas', 'Gasolina'];
  final double _latitude = -17.780578;
  final double _longitude = -63.1921634;
  final int _quantity = 5;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('https://easypay.lat/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          await prefs.remove('auth_token');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cerrar sesión')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _calculateStationCountsByCity() {
    _stationCountByCity.clear();
    for (var city in _cities) {
      _stationCountByCity[city['code']] = 0;
    }

    for (var station in _stations) {
      bool fuelMatch = station.mainFuelType == _selectedFuelType;
      if (fuelMatch) {
        for (var city in _cities) {
          if (city['name'] == 'All Cities') {
            _stationCountByCity[city['code']] =
                (_stationCountByCity[city['code']] ?? 0) + 1;
          } else if (station.city
              .toLowerCase()
              .contains(city['name'].toLowerCase())) {
            _stationCountByCity[city['code']] =
                (_stationCountByCity[city['code']] ?? 0) + 1;
            break;
          }
        }
      }
    }
  }

  Future<void> _fetchStations({String fuelType = 'Diesel'}) async {
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inSeconds < 10) {
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'No hay conexión a internet';
        _isLoading = false;
      });
      return;
    }

    final cacheKey = fuelType;
    if (_stationCache.containsKey(cacheKey)) {
      setState(() {
        _stations = _stationCache[cacheKey]!;
        _isLoading = false;
        _errorMessage = null;
        _calculateStationCountsByCity();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stations = [];
    });

    try {
      final fuelId = _fuelTypes.indexOf(fuelType) + 1;
      final response = await http.get(
        Uri.parse(
            '$_apiUrl?fuel=$fuelId&Latitude=$_latitude&Longitude=$_longitude&Quantity=$_quantity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic UEVUUk9CT1hfU1RPQ0s6UEVUUk9CT1hfU1RPQ0s=',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      if (response.statusCode == 200) {
        final parsedData = await parseStations(
            response.body); // Removed compute for simplicity
        setState(() {
          _stations = parsedData['stations'];
          _stationCache[cacheKey] = _stations;
          _isLoading = false;
          _calculateStationCountsByCity();
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar datos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    } finally {
      _lastFetchTime = DateTime.now();
    }
  }

  List<Station> get filteredStations => _stations.where((station) {
        bool cityMatch = _selectedCity == null ||
            _selectedCity == 'All Cities' ||
            station.city.toLowerCase().contains(_selectedCity!.toLowerCase());
        bool fuelMatch = station.mainFuelType == _selectedFuelType;
        return cityMatch && fuelMatch;
      }).toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));

  Widget _buildFuelTypeSelectionScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.032,
          ),
          child: Image.asset(
            'assets/images/logo.png',
            height: MediaQuery.of(context).size.height * 0.09,
            width: MediaQuery.of(context).size.width * 0.18,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
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
          _selectedFuelType = fuelType;
          _currentScreen = 1;
          _calculateStationCountsByCity();
          _fetchStations(fuelType: fuelType);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : IndexedStack(
                  index: _currentScreen,
                  children: [
                    _buildFuelTypeSelectionScreen(context),
                    _buildCityFilterScreen(context),
                    _buildStationListScreen(context),
                  ],
                ),
    );
  }

  Widget _buildCityFilterScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _currentScreen = 0;
              _selectedCity = null;
            });
          },
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: MediaQuery.of(context).size.height * 0.05,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
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
              Wrap(
                spacing: MediaQuery.of(context).size.width * 0.041,
                runSpacing: MediaQuery.of(context).size.height * 0.019,
                children: _cities.map((city) {
                  final cityCode = city['code'];
                  final stationCount = _stationCountByCity[cityCode] ?? 0;
                  final countText = stationCount == 1
                      ? '1 Estación'
                      : '$stationCount Estaciones';

                  return _buildCityCard(
                    city['name'],
                    countText,
                    city['code'],
                    context,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(
      String city, String dispensers, int code, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCity = city;
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
                textAlign: TextAlign.center,
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

  Widget _buildStationListScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _currentScreen = 1;
              _selectedCity = null;
            });
          },
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: MediaQuery.of(context).size.height * 0.05,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
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
                'Estaciones en ${_selectedCity ?? 'Bolivia'}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.051,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
              if (filteredStations.isEmpty)
                const Center(
                  child: Text(
                    'No se encontraron estaciones para este combustible o ciudad',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ListView.builder(
                key: ValueKey(
                    '${_selectedCity}_${_selectedFuelType}_${filteredStations.length}'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredStations.length,
                itemBuilder: (context, index) {
                  final station = filteredStations[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStation = station.name;
                      });
                    },
                    onLongPress: () => _showNavigationOptions(station, context),
                    child: _buildStationCard(station, context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(Station station, BuildContext context) {
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
                Flexible(
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _selectedStation == station.name
                      ? Icons.star
                      : Icons.star_border,
                  size: MediaQuery.of(context).size.width * 0.061,
                  color: const Color(0xFFFFC107),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.019),
            Text(
              station.address,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A0A0),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              station.displayFuelType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              station.vehicleCount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFC107),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              station.lastUpdated,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFA0A0A0),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Text(
              'Distancia: ${station.distance.toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFA0A0A0),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.014),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton('Google', Icons.map, station.address,
                    station.rawAddress, context),
                _buildNavigationButton('Waze', Icons.directions,
                    station.address, station.rawAddress, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String label, IconData icon, String address,
      String rawAddress, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.359,
      height: MediaQuery.of(context).size.height * 0.057,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E2E2E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.031),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
        ),
        onPressed: () =>
            _launchEnhancedNavigation(label, address, context, rawAddress),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.width * 0.05,
              color: const Color(0xFFFFC107),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text(
              label,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _enhancedWazeAddress(String rawAddress, String city) {
    final addressParts = rawAddress.split(',');
    String streetAddress = addressParts.first.trim();

    Map<String, String> abbreviations = {
      'Nº': '',
      'Z/': 'Zona ',
      'Av.': 'Avenida',
      'Av ': 'Avenida ',
      'Calle': '',
      'C.': '',
      'C/': '',
      '#': '',
      'No.': '',
      'No ': '',
      'Esq.': 'Esquina',
      'Edif.': 'Edificio',
      'Piso ': 'P',
    };

    String cleaned = streetAddress;
    abbreviations.forEach((abbr, replacement) {
      cleaned = cleaned.replaceAll(abbr, replacement);
    });

    cleaned = cleaned
        .replaceAll(RegExp(r'[^\w\s0-9]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (city.isNotEmpty && city != 'All Cities') {
      return '$cleaned, $city, Bolivia';
    } else {
      return '$cleaned, Bolivia';
    }
  }

  Future<List<String>> _getWazeUrls(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    return [
      'waze://?q=$encodedAddress&navigate=yes',
      'https://waze.com/ul?q=$encodedAddress&navigate=yes',
    ];
  }

  Future<String> _getPreferredNavigationApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_nav_app') ?? 'Waze';
  }

  Future<void> _setPreferredNavigationApp(String app) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_nav_app', app);
  }

  Future<void> _launchEnhancedNavigation(String app, String address,
      BuildContext context, String rawAddress) async {
    try {
      final String cityName = _selectedCity ?? 'Bolivia';

      if (app == 'Google') {
        final encodedAddress = Uri.encodeComponent(address);
        final url =
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'No se pudo abrir Google Maps';
        }
      } else if (app == 'Waze') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preparando navegación...'),
            duration: Duration(seconds: 1),
          ),
        );

        final String wazeAddress = _enhancedWazeAddress(rawAddress, cityName);
        final List<String> wazeUrls = await _getWazeUrls(wazeAddress);

        bool launched = false;
        for (final url in wazeUrls) {
          if (!launched) {
            try {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
                launched = true;
                await _setPreferredNavigationApp('Waze');
                break;
              }
            } catch (e) {
              print('Failed to launch Waze with URL $url');
            }
          }
        }

        if (!launched) {
          final encodedAddress = Uri.encodeComponent(address);
          final googleUrl =
              'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
          if (await canLaunchUrl(Uri.parse(googleUrl))) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir Waze. Abriendo Google Maps.'),
                duration: Duration(seconds: 2),
              ),
            );
            await launchUrl(Uri.parse(googleUrl),
                mode: LaunchMode.externalApplication);
            launched = true;
          }
        }

        if (!launched) {
          throw 'No se pudo abrir ninguna aplicación de navegación';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir la navegación: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showNavigationOptions(
      Station station, BuildContext context) async {
    final String? selectedApp = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text('Navegar a estación',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(station.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(station.address,
                  style: const TextStyle(color: Color(0xFFA0A0A0))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Waze'),
              child: const Text('Waze',
                  style: TextStyle(color: Color(0xFFFFC107))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Google'),
              child: const Text('Google Maps',
                  style: TextStyle(color: Color(0xFFFFC107))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (selectedApp != null) {
      await _launchEnhancedNavigation(
          selectedApp, station.address, context, station.rawAddress);
      await _setPreferredNavigationApp(selectedApp);
    }
  }
}
