import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/team_model.dart';
import 'model/player_model.dart';
import 'player_details.dart';
import 'model/afl_models.dart';

class TeamDetails extends StatefulWidget {
  final String? id;
  const TeamDetails({Key? key, this.id}) : super(key: key);

  @override
  State<TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var teamModel = Provider.of<TeamModel>(context, listen: false);
    var playerModel = Provider.of<PlayerModel>(context);
    var team = teamModel.get(widget.id);

    var adding = team == null;
    if (!adding) {
      nameController.text = team.name;
    }

    var players = adding
        ? <Player>[]
        : playerModel.items.where((p) => team!.players.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Team' : 'Edit Team'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: adding
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerDetails(teamId: team!.id),
                      ),
                    );
                  },
            icon: const Icon(Icons.person_add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: nameController,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (_, index) {
                    var p = players[index];
                    return ListTile(
                      leading: p.image != null ? Image.memory(base64Decode(p.image!), width: 40) : null,
                      title: Text(p.name),
                      subtitle: Text('No. ${p.number}'),
                    );
                  },
                ),
              ),
              Consumer<TeamModel>(
                builder: (_, model, __) => ElevatedButton.icon(
                  onPressed: model.loading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (adding) {
                              team = Team(name: '');
                            }
                            team!.name = nameController.text;
                            if (adding) {
                              await model.add(team!);
                            } else {
                              await model.updateItem(widget.id!, team!);
                            }
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
