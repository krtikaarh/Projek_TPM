import 'package:flutter/material.dart';
import 'package:projek_tpm/models/pet_model.dart';
import 'package:projek_tpm/screens/pet/pet_form_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<Pet> pets = [];
  List<dynamic> apiPets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
    _loadApiPets();
  }

  Future<void> _loadPets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> petStrings = prefs.getStringList('pets') ?? [];
    setState(() {
      pets = petStrings.map((str) => Pet.fromJson(json.decode(str))).toList();
    });
  }

  Future<void> _savePets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> petStrings =
        pets.map((pet) => json.encode(pet.toJson())).toList();
    await prefs.setStringList('pets', petStrings);
  }

  Future<void> _loadApiPets() async {
    try {
      final response = await http.get(
        Uri.parse('https://6842dfb6e1347494c31e4678.mockapi.io/allPets/pets'),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiPets = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error loading API pets: $e');
    }
  }

  void _addPet() {
    showDialog(
      context: context,
      builder:
          (context) => PetFormDialog(
            onSave: (pet) {
              setState(() {
                pets.add(pet);
              });
              _savePets();
            },
          ),
    );
  }

  void _editPet(int index) {
    showDialog(
      context: context,
      builder:
          (context) => PetFormDialog(
            pet: pets[index],
            onSave: (pet) {
              setState(() {
                pets[index] = pet;
              });
              _savePets();
            },
          ),
    );
  }

  void _deletePet(int index) {
    setState(() {
      pets.removeAt(index);
    });
    _savePets();
  }

  void _duplicateFromApi(dynamic apiPet) {
    Pet newPet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: apiPet['name'] ?? 'Unknown',
      type: apiPet['type'] ?? 'Unknown',
      lastVaccination: DateTime.now().subtract(Duration(days: 30)),
      nextVaccination: DateTime.now().add(Duration(days: 335)),
      lastBath: DateTime.now().subtract(Duration(days: 7)),
      nextBath: DateTime.now().add(Duration(days: 23)),
      estimatedCost: double.tryParse(apiPet['cost']?.toString() ?? '0') ?? 0.0,
    );

    setState(() {
      pets.add(newPet);
    });
    _savePets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Care Reminder'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: _loadApiPets,
            tooltip: 'Load API Templates',
          ),
        ],
      ),
      body: Column(
        children: [
          if (apiPets.isNotEmpty) ...[
            Container(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Pet List :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: apiPets.length,
                      itemBuilder: (context, index) {
                        final apiPet = apiPets[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => _duplicateFromApi(apiPet),
                            child: Container(
                              width: 120,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  apiPet['fotoUrl'] != null &&
                                          apiPet['fotoUrl']
                                              .toString()
                                              .isNotEmpty
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          apiPet['fotoUrl'],
                                        ),
                                        radius: 20,
                                      )
                                      : Icon(Icons.pets, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    apiPet['name'] ?? 'Unknown',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    apiPet['type'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (apiPet['ras'] != null &&
                                      apiPet['ras'].toString().isNotEmpty)
                                    Text(
                                      apiPet['ras'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: pets.length + apiPets.length,
              itemBuilder: (context, index) {
                if (index < pets.length) {
                  // Local pets
                  final pet = pets[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            pet.fotoUrl != null && pet.fotoUrl!.isNotEmpty
                                ? NetworkImage(pet.fotoUrl!)
                                : null,
                        child:
                            (pet.fotoUrl == null || pet.fotoUrl!.isEmpty)
                                ? Text(pet.name[0].toUpperCase())
                                : null,
                      ),
                      title: Text(pet.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${pet.type}'),
                          if (pet.ras != null && pet.ras!.isNotEmpty)
                            Text('Ras: ${pet.ras}'),
                          if (pet.umur != null) Text('Umur: ${pet.umur} tahun'),
                          if (pet.catatan != null && pet.catatan!.isNotEmpty)
                            Text('Catatan: ${pet.catatan}'),
                          Text(
                            'Next Vaccination: ${_formatDate(pet.nextVaccination)}',
                          ),
                          Text('Next Bath: ${_formatDate(pet.nextBath)}'),
                          if (pet.estimatedCost > 0)
                            Text(
                              'Estimated Cost: Rp ${pet.estimatedCost.toStringAsFixed(0)}',
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editPet(index);
                          } else if (value == 'delete') {
                            _deletePet(index);
                          }
                        },
                      ),
                    ),
                  );
                } else {
                  // API pets
                  final apiPet = apiPets[index - pets.length];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (apiPet['fotoUrl'] != null &&
                                    apiPet['fotoUrl'].toString().isNotEmpty)
                                ? NetworkImage(apiPet['fotoUrl'])
                                : null,
                        child:
                            (apiPet['fotoUrl'] == null ||
                                    apiPet['fotoUrl'].toString().isEmpty)
                                ? Text((apiPet['name'] ?? 'U')[0].toUpperCase())
                                : null,
                      ),
                      title: Text(apiPet['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${apiPet['type'] ?? 'Unknown'}'),
                          if (apiPet['ras'] != null &&
                              apiPet['ras'].toString().isNotEmpty)
                            Text('Ras: ${apiPet['ras']}'),
                          if (apiPet['umur'] != null)
                            Text('Umur: ${apiPet['umur']} tahun'),
                          if (apiPet['catatan'] != null &&
                              apiPet['catatan'].toString().isNotEmpty)
                            Text('Catatan: ${apiPet['catatan']}'),
                          if (apiPet['cost'] != null)
                            Text('Estimated Cost: Rp ${apiPet['cost']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        tooltip: 'Add to My Pets',
                        onPressed: () => _duplicateFromApi(apiPet),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPet,
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
