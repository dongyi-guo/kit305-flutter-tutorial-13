import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/afl_models.dart';
import 'player_form.dart';
import 'model/match_model.dart';
import 'match_briefing.dart';

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
        return _playerStep(teamBPlayers, 'Team B', nextLabel: 'Create Match');
      default:
        return _teamNameStep();
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
                if (teamAController.text.trim().isEmpty ||
                    teamBController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Team names required')));
                  return;
                }
                setState(() => step = 1);
              },
              child: const Text('Next'),
            )
          ],
        ),
      ),
    );
  }

  Widget _playerStep(List<Player> players, String title,
      {String nextLabel = 'Next'}) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Players - $title'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var numbers = players.map((p) => p.number).toList();
          var player = await Navigator.push<Player?>(
              context,
              MaterialPageRoute(
                  builder: (_) => PlayerForm(takenNumbers: numbers)));
          if (player != null) {
            setState(() {
              players.add(player);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text(
                  'Add players using the + button. Each team needs at least two players.'))
          : ListView.builder(
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
                      var numbers = players
                          .where((other) => other != p)
                          .map((other) => other.number)
                          .toList();
                      var updated = await Navigator.push<Player?>(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PlayerForm(player: p, takenNumbers: numbers)));
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
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => step--);
                  },
                  child: const Text('Back'),
                ),
              ),
            if (step > 0) const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (step == 1 && teamAPlayers.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add at least two players')));
                    return;
                  }
                  if (step == 2) {
                    if (teamBPlayers.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add at least two players')));
                      return;
                    }
                    if (teamBPlayers.length != teamAPlayers.length) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Teams must have equal number of players')));
                      return;
                    }
                    _saveMatch();
                    return;
                  }
                  setState(() => step++);
                },
                child: Text(nextLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _saveMatch() async {
    if (teamAPlayers.length < 2 ||
        teamBPlayers.length < 2 ||
        teamAPlayers.length != teamBPlayers.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Each team needs an equal number of at least two players')));
      return;
    }

    var matchModel = Provider.of<MatchModel>(context, listen: false);

    var match = MatchData(
      teamAName: teamAController.text,
      teamBName: teamBController.text,
      teamAPlayers: teamAPlayers,
      teamBPlayers: teamBPlayers,
    );
    match.id = await matchModel.add(match);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MatchBriefingPage(matchId: match.id)),
    );
  }
}
