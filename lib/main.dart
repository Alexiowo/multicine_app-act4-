import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MulticineApp());
}
class ApiService {
  static const String baseUrl = 'http://192.168.0.2:8000/api/cartelera';

  static Future<List<dynamic>> getCartelera() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar cartelera');
    }
  }
}

class MulticineApp extends StatelessWidget {
  const MulticineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multicine Universal',
      theme: ThemeData(
        primaryColor: const Color(0xFF6A1B9A),
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B1FA2),
          primary: const Color(0xFF7B1FA2),
          secondary: const Color(0xFF42A5F5),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5E35B1),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ======================= LOGIN =======================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Image.asset('assets/logo.png', height: 130),

              const SizedBox(height: 25),

              const Text(
                'Multicine Universal',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Reserva y compra de boletos',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),

                  label: const Text(
                    'Continuar con Google',
                    style: TextStyle(fontSize: 18),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= HOME =======================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String getImagePath(String imageName) {
    return 'assets/movies/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartelera'), centerTitle: true),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getCartelera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final peliculas = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula = peliculas[index];

              final funciones = pelicula['funciones'] as List;

              final schedules = funciones.map<String>((funcion) {
                final hora = funcion['hora'].toString().substring(0, 5);
                final sala = funcion['sala']['nombre_sala'];
                return '$hora - $sala';
              }).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: MovieCard(
                  title: pelicula['titulo'],
                  image: getImagePath(pelicula['imagen']),
                  schedules: schedules,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String image;
  final List<String> schedules;

  const MovieCard({
    super.key,
    required this.title,
    required this.image,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 143, 88, 167),
            Color.fromARGB(255, 114, 172, 219),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),

              child: Image.asset(
                image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // CONTENIDO
            Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITULO
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TEXTO HORARIOS
                  const Text(
                    'Horarios Disponibles',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTONES HORARIOS
                  Column(
                    children: schedules.map((schedule) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.schedule),

                            onPressed: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => SeatSelectionScreen(
                                    movieTitle: title,
                                    schedule: schedule,
                                  ),
                                ),
                              );
                            },

                            label: Text(schedule),
                          ),
                        ),
                      );
                    }).toList(),
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

// ======================= SEAT SELECTION =======================
class SeatSelectionScreen extends StatelessWidget {
  final String movieTitle;
  final String schedule;

  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Asientos')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(height: 10, width: double.infinity, color: Colors.black),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.builder(
                itemCount: 30,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'A${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        movieTitle: movieTitle,
                        schedule: schedule,
                      ),
                    ),
                  );
                },
                child: const Text('Continuar al Pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= PAYMENT =======================
class PaymentScreen extends StatelessWidget {
  final String movieTitle;
  final String schedule;

  const PaymentScreen({
    super.key,
    required this.movieTitle,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Digital')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Compra',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Película'),
              subtitle: Text(movieTitle),
            ),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horario y Sala'),
              subtitle: Text(
                schedule,
                style: const TextStyle(
                  color: Color.fromARGB(179, 14, 13, 13),
                  fontSize: 16,
                ),
              ),
            ),

            const ListTile(
              leading: Icon(Icons.event_seat),
              title: Text('Asientos'),
              subtitle: Text('A1, A2'),
            ),

            const ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Total'),
              subtitle: Text('50 Bs'),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrPaymentScreen(
                        movieTitle: movieTitle,
                        schedule: schedule,
                      ),
                    ),
                  );
                },
                child: const Text('Pagar Ahora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ======================= QR PAYMENT =======================

class QrPaymentScreen extends StatelessWidget {
  final String movieTitle;
  final String schedule;

  const QrPaymentScreen({
    super.key,
    required this.movieTitle,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago QR')),

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              'Escanea el código QR para realizar el pago',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black12),
                ],
              ),

              child: const Icon(
                Icons.qr_code_2,
                size: 220,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Monto a pagar: 50 Bs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),

                label: const Text('Confirmar Pago'),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketScreen(
                        movieTitle: movieTitle,
                        schedule: schedule,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= TICKET =======================
class TicketScreen extends StatelessWidget {
  final String movieTitle;
  final String schedule;

  const TicketScreen({
    super.key,
    required this.movieTitle,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boleto Digital')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2, size: 120, color: Colors.black),

                  const SizedBox(height: 20),

                  const Text(
                    'E-Ticket',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const Divider(height: 30),

                  ticketInfo('Película', movieTitle),
                  ticketInfo('Horario y Sala', schedule),
                  ticketInfo('Asientos', 'A1, A2'),
                  ticketInfo('Fecha', '14/05/2026'),
                  ticketInfo('Total', '50 Bs'),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Código de reserva: MCU-2026-001',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Volver al Inicio'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget ticketInfo(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    ),
  );
}
