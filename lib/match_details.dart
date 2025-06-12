import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match_model.dart';
import 'afl_models.dart';

/// Form used for creating or editing a [MatchData] entry.
class MatchDetails extends StatefulWidget {
  final String? id;
  const MatchDetails({Key? key, this.id}) : super(key: key);

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  final _formKey = GlobalKey<FormState>();
  final teamAController = TextEditingController();
  final teamBController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<MatchModel>(context, listen: false);
    var match = model.get(widget.id);

    var adding = match == null;
    if (!adding) {
      teamAController.text = match.teamAId;
      teamBController.text = match.teamBId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Match' : 'Edit Match'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Team A'),
                controller: teamAController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Team B'),
                controller: teamBController,
              ),
              Consumer<MatchModel>(
                builder: (_, matchModel, __) => ElevatedButton.icon(
                  onPressed: matchModel.loading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (adding) {
                              match = MatchData(teamAId: '', teamBId: '');
                            }
                            match!.teamAId = teamAController.text;
                            match!.teamBId = teamBController.text;
                            if (adding) {
                              await matchModel.add(match!);
                            } else {
                              await matchModel.updateItem(widget.id!, match!);
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

