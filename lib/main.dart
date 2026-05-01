import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MiAppPeliculas());
}

class MiAppPeliculas extends StatelessWidget {
  const MiAppPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo Pokémon',
      home: const PantallaInicio(),
    );
  }
}

class Pokemon {
  final String nombre;
  final int altura;
  final int peso;
  final String imagen;

  Pokemon({
    required this.nombre,
    required this.altura,
    required this.peso,
    required this.imagen,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      nombre: json['name'],
      altura: json['height'],
      peso: json['weight'],
      imagen: json['sprites']['front_default'],
    );
  }
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<Pokemon> pokemonFuture;
final TextEditingController controladorPokemon = TextEditingController();
 Future<Pokemon> obtenerPokemon(String nombrePokemon) async {
  final respuesta = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$nombrePokemon'),
  );

  if (respuesta.statusCode == 200) {
    return Pokemon.fromJson(jsonDecode(respuesta.body));
  } else {
    throw Exception('No se encontró el Pokémon');
  }
}

  @override
  void initState() {
    super.initState();
    pokemonFuture = obtenerPokemon('pikachu');
  }
  void buscarPokemon() {
  final nombre = controladorPokemon.text.toLowerCase().trim();

  if (nombre.isNotEmpty) {
    setState(() {
      pokemonFuture = obtenerPokemon(nombre);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Catálogo Pokémon'),
        centerTitle: true,
      ),
body: Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      TextField(
        controller: controladorPokemon,
        decoration: const InputDecoration(
          labelText: 'Escribe el nombre del Pokémon',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: buscarPokemon,
        child: const Text('Buscar Pokémon'),
      ),
      const SizedBox(height: 30),
      Expanded(
        child: Center(
          child: FutureBuilder<Pokemon>(
            future: pokemonFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pokemon = snapshot.data!;

                return Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          pokemon.imagen,
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          pokemon.nombre.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Altura: ${pokemon.altura}'),
                        Text('Peso: ${pokemon.peso}'),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Text(
                  'No se encontró el Pokémon. Intenta con otro nombre.',
                  textAlign: TextAlign.center,
                );
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    ],
  ),
)    );
  }
}