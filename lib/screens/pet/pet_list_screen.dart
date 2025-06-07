import 'package:flutter/material.dart';
import 'package:projek_tpm/models/pet_model.dart';
import 'package:projek_tpm/screens/pet/pet_form_dialog.dart';
import 'package:projek_tpm/screens/profile_screen.dart';
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
  bool isLoadingApi = false;
  String apiError = '';

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
    setState(() {
      isLoadingApi = true;
      apiError = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://6842dfb6e1347494c31e4678.mockapi.io/allPets/pets'),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiPets = json.decode(response.body);
          isLoadingApi = false;
        });
      } else {
        setState(() {
          apiError = 'Failed to load data: ${response.statusCode}';
          isLoadingApi = false;
        });
      }
    } catch (e) {
      setState(() {
        apiError = 'Error loading API pets: $e';
        isLoadingApi = false;
      });
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Pet'),
            content: Text(
              'Are you sure you want to delete ${pets[index].name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    pets.removeAt(index);
                  });
                  _savePets();
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _duplicateFromApi(dynamic apiPet) {
    // Menggunakan nama dan type dari API dengan fallback
    final String petName =
        apiPet['nama']?.toString() ?? apiPet['name']?.toString() ?? 'Unknown';
    final String petType = apiPet['type']?.toString() ?? 'Unknown';

    Pet newPet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: petName,
      type: petType,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newPet.name} added to your pets!')),
    );
  }

  // Navigasi ke halaman profile
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  Widget _buildApiPetsSection() {
    if (isLoadingApi) {
      return Container(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (apiError.isNotEmpty) {
      return Container(
        height: 140,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Failed to load pet templates',
              style: TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              apiError,
              style: TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            TextButton(onPressed: _loadApiPets, child: Text('Retry')),
          ],
        ),
      );
    }

    if (apiPets.isEmpty) {
      return Container(
        height: 140,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No pet templates available',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pet Templates (${apiPets.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadApiPets,
                  tooltip: 'Refresh templates',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: apiPets.length,
              itemBuilder: (context, index) {
                final apiPet = apiPets[index];
                // Ambil data sesuai field API
                final String petName = apiPet['nama']?.toString() ?? 'Unknown';
                final String petType = apiPet['type']?.toString() ?? '-';
                final String petRas = apiPet['ras']?.toString() ?? '-';
                final String petUmur = apiPet['umur']?.toString() ?? '-';
                final String petCatatan = apiPet['catatan']?.toString() ?? '-';
                final String petFoto = apiPet['fotoUrl']?.toString() ?? '';
                final String petCost = apiPet['cost']?.toString() ?? '-';

                return GestureDetector(
                  onTap: () => _showApiPetDetail(apiPet),
                  child: Card(
                    margin: EdgeInsets.only(right: 12, top: 4, bottom: 4),
                    elevation: 2,
                    child: Container(
                      width: 160,
                      height: 180,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          petFoto.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  petFoto,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          CircleAvatar(
                                            radius: 24,
                                            child: Icon(Icons.pets, size: 24),
                                          ),
                                ),
                              )
                              : CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.pets, size: 24),
                              ),
                          SizedBox(height: 10),
                          Text(
                            petName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            petType,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ras: $petRas',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Umur: $petUmur',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tap for details',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue[700],
                              ),
                            ),
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
    );
  }

  void _showApiPetDetail(dynamic apiPet) {
    // Ambil data sesuai field API
    final String petName = apiPet['nama']?.toString() ?? 'Unknown';
    final String petType = apiPet['type']?.toString() ?? '-';
    final String petRas = apiPet['ras']?.toString() ?? '-';
    final String petUmur = apiPet['umur']?.toString() ?? '-';
    final String petCatatan = apiPet['catatan']?.toString() ?? '-';
    final String petFoto = apiPet['fotoUrl']?.toString() ?? '';
    final String petCost = apiPet['cost']?.toString() ?? '-';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(petName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (petFoto.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      petFoto,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.pets, size: 40),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12),
              Text('Type: $petType'),
              Text('Breed: $petRas'),
              Text('Age: $petUmur years'),
              Text('Notes: $petCatatan'),
              Text('Estimated Cost: Rp $petCost'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPetsSection() {
    if (pets.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No pets yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'Add your first pet or select from templates above',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'My Pets (${pets.length})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isVaccinationDue =
                    pet.nextVaccination.difference(DateTime.now()).inDays <= 7;
                final isBathDue =
                    pet.nextBath.difference(DateTime.now()).inDays <= 3;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          pet.fotoUrl != null && pet.fotoUrl!.isNotEmpty
                              ? NetworkImage(pet.fotoUrl!)
                              : null,
                      child:
                          (pet.fotoUrl == null || pet.fotoUrl!.isEmpty)
                              ? Text(
                                pet.name[0].toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                              : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(pet.name)),
                        if (isVaccinationDue)
                          Icon(Icons.vaccines, color: Colors.red, size: 16),
                        if (isBathDue)
                          Icon(Icons.shower, color: Colors.orange, size: 16),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${pet.type}'),
                        if (pet.ras != null && pet.ras!.isNotEmpty)
                          Text('Breed: ${pet.ras}'),
                        Text(
                          'Next Vaccination: ${_formatDate(pet.nextVaccination)}',
                          style: TextStyle(
                            color: isVaccinationDue ? Colors.red : null,
                          ),
                        ),
                        Text(
                          'Next Bath: ${_formatDate(pet.nextBath)}',
                          style: TextStyle(
                            color: isBathDue ? Colors.orange : null,
                          ),
                        ),
                        if (pet.estimatedCost > 0)
                          Text(
                            'Estimated Cost: Rp ${pet.estimatedCost.toStringAsFixed(0)}',
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Care Reminder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person), // Ganti dari refresh ke profile icon
            onPressed: _navigateToProfile, // Navigasi ke halaman profile
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildApiPetsSection(),
          Divider(height: 1),
          _buildMyPetsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPet,
        child: Icon(Icons.add),
        tooltip: 'Add new pet',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
