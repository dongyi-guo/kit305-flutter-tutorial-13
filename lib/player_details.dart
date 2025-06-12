import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'player_model.dart';
import 'team_model.dart';
import 'afl_models.dart';

class PlayerDetails extends StatefulWidget {
  final String? id;
  final String? teamId;
  const PlayerDetails({Key? key, this.id, this.teamId}) : super(key: key);

  @override
  State<PlayerDetails> createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    var playerModel = Provider.of<PlayerModel>(context, listen: false);
    var player = playerModel.get(widget.id);

    var adding = player == null;
    if (!adding) {
      nameController.text = player.name;
      numberController.text = player.number.toString();
      imagePath = player.image;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Player' : 'Edit Player'),
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
                    setState(() {
                      imagePath = image.path;
                    });
                  }
                },
                icon: const Icon(Icons.photo),
                label: const Text('Select Photo'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: nameController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number'),
                controller: numberController,
                keyboardType: TextInputType.number,
              ),
              Consumer<PlayerModel>(
                builder: (_, model, __) => ElevatedButton.icon(
                  onPressed: model.loading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (adding) {
                              player = Player(name: '', number: 0);
                            }
                            player!.name = nameController.text;
                            player!.number = int.tryParse(numberController.text) ?? 0;
                            player!.image = imagePath;
                            if (adding) {
                              String newId = await model.add(player!);
                              if (widget.teamId != null) {
                                var teamModel = Provider.of<TeamModel>(context, listen: false);
                                var team = teamModel.get(widget.teamId);
                                if (team != null) {
                                  team.players.add(newId);
                                  await teamModel.updateItem(team.id, team);
                                }
                              }
                            } else {
                              await model.updateItem(widget.id!, player!);
                            }
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
