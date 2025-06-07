import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet_model.dart';

class ApiService {
  static const String baseUrl = 'https://6842dfb6e1347494c31e4678.mockapi.io/allPets/pets';

  Future<List<Pet>> fetchPets() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Pet.fromJson(e)).toList();
    }
    throw Exception('Failed to load pets');
  }

  Future<void> addPet(Pet pet) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pet.toJson()),
    );
  }
}