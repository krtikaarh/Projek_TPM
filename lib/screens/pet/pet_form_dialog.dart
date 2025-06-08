import 'package:flutter/material.dart';
import 'package:projek_tpm/models/pet_model.dart';

class PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSave;

  PetFormDialog({this.pet, required this.onSave});

  @override
  _PetFormDialogState createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _costController;
  late DateTime _nextVaccination;
  late DateTime _nextBath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _typeController = TextEditingController(text: widget.pet?.type ?? '');
    _costController = TextEditingController(
      text: widget.pet?.estimatedCost?.toString() ?? '0',
    );
    _nextVaccination =
        widget.pet?.nextVaccination ?? DateTime.now().add(Duration(days: 365));
    _nextBath = widget.pet?.nextBath ?? DateTime.now().add(Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? 'Add Pet' : 'Edit Pet'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Pet Name'),
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Pet Type (e.g., Dog, Cat)',
                ),
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Please enter a type' : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(labelText: 'Estimated Cost (Rp)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Next Vaccination'),
                subtitle: Text(_formatDate(_nextVaccination)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _nextVaccination,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 730)),
                  );
                  if (date != null) {
                    setState(() => _nextVaccination = date);
                  }
                },
              ),
              ListTile(
                title: Text('Next Bath'),
                subtitle: Text(_formatDate(_nextBath)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _nextBath,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _nextBath = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final pet = Pet(
                id:
                    widget.pet?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                type: _typeController.text,
                lastVaccination:
                    widget.pet?.lastVaccination ??
                    DateTime.now().subtract(Duration(days: 30)),
                nextVaccination: _nextVaccination,
                lastBath:
                    widget.pet?.lastBath ??
                    DateTime.now().subtract(Duration(days: 7)),
                nextBath: _nextBath,
                estimatedCost: double.tryParse(_costController.text) ?? 0.0,
              );
              widget.onSave(pet);
              Navigator.pop(context);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
