import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'model/afl_models.dart';

/// Form used for creating or editing a [Player] without touching Firestore.
class PlayerForm extends StatefulWidget {
  final Player? player;
  final List<int> takenNumbers;
  const PlayerForm({Key? key, this.player, this.takenNumbers = const []})
      : super(key: key);

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  String? imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      nameController.text = widget.player!.name;
      numberController.text = widget.player!.number.toString();
      imagePath = widget.player!.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player == null ? 'Add Player' : 'Edit Player'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (imagePath != null)
                Image.file(File(imagePath!), height: 120),
              TextButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final dir = await getApplicationDocumentsDirectory();
                    final fileName = p.basename(image.path);
                    final saved = await File(image.path).copy(p.join(dir.path, fileName));
                    setState(() {
                      imagePath = saved.path;
                    });
                  }
                },
                icon: const Icon(Icons.photo),
                label: const Text('Select Photo'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: nameController,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number'),
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    int num = int.tryParse(numberController.text) ?? 0;
                    if (widget.takenNumbers.contains(num)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Duplicate player number')));
                      return;
                    }
                    var player = widget.player ?? Player(name: '', number: 0);
                    player.name = nameController.text;
                    player.number = num;
                    player.image = imagePath;
                    Navigator.pop(context, player);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
