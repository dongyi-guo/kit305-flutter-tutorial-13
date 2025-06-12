import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'afl_models.dart';
import 'player_form.dart';
import 'team_model.dart';
import 'player_model.dart';
import 'match_model.dart';

/// Step based UI for creating a match with teams and players.
class NewMatchFlow extends StatefulWidget {
  const NewMatchFlow({Key? key}) : super(key: key);

  @override
  State<NewMatchFlow> createState() => _NewMatchFlowState();
}

class _NewMatchFlowState extends State<NewMatchFlow> {
  int step = 0;
  final teamAController = TextEditingController();
  final teamBController = TextEditingController();

  final List<Player> teamAPlayers = [];
  final List<Player> teamBPlayers = [];

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _teamNameStep();
      case 1:
        return _playerStep(teamAPlayers, 'Team A', nextLabel: 'Next');
      case 2:
        return _playerStep(teamBPlayers, 'Team B', nextLabel: 'Summary');
      default:
        return _summaryStep();
    }
  }

  Widget _teamNameStep() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: teamAController,
              decoration: const InputDecoration(labelText: 'Team A Name'),
            ),
            TextField(
              controller: teamBController,
              decoration: const InputDecoration(labelText: 'Team B Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => step = 1);
              },
              child: const Text('Next'),
            )
          ],
        ),
      ),
    );
  }

  Widget _playerStep(List<Player> players, String title, {String nextLabel = 'Next'}) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Players - $title'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var player = await Navigator.push<Player?>(
              context, MaterialPageRoute(builder: (_) => const PlayerForm()));
          if (player != null) {
            setState(() {
              players.add(player);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (_, index) {
          var p = players[index];
          return Dismissible(
            key: Key('$index${p.name}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              setState(() {
                players.removeAt(index);
              });
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('No. ${p.number}'),
              onTap: () async {
                var updated = await Navigator.push<Player?>(
                    context, MaterialPageRoute(builder: (_) => PlayerForm(player: p)));
                if (updated != null) {
                  setState(() {
                    players[index] = updated;
                  });
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () {
            setState(() => step++);
          },
          child: Text(nextLabel),
        ),
      ),
    );
  }

  Widget _summaryStep() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text('Team A: ${teamAController.text}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...teamAPlayers.map((p) => Text(' - ${p.name} (#${p.number})')),
          const SizedBox(height: 10),
          Text('Team B: ${teamBController.text}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...teamBPlayers.map((p) => Text(' - ${p.name} (#${p.number})')),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveMatch,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMatch() async {
    var teamModel = Provider.of<TeamModel>(context, listen: false);
    var playerModel = Provider.of<PlayerModel>(context, listen: false);
    var matchModel = Provider.of<MatchModel>(context, listen: false);

    // Save team A and players
    var teamA = Team(name: teamAController.text);
    teamA.id = await teamModel.add(teamA);
    for (var p in teamAPlayers) {
      var id = await playerModel.add(p);
      teamA.players.add(id);
    }
    await teamModel.updateItem(teamA.id, teamA);

    // Save team B
    var teamB = Team(name: teamBController.text);
    teamB.id = await teamModel.add(teamB);
    for (var p in teamBPlayers) {
      var id = await playerModel.add(p);
      teamB.players.add(id);
    }
    await teamModel.updateItem(teamB.id, teamB);

    // Save match
    var match = MatchData(teamAId: teamA.id, teamBId: teamB.id);
    await matchModel.add(match);

    if (mounted) Navigator.pop(context);
  }
}
