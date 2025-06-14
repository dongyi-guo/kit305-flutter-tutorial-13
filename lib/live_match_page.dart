import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/afl_models.dart';
import 'model/match_model.dart';

/// Simple live match recording page that lets users
/// select a player and record actions for them.
class LiveMatchPage extends StatefulWidget {
  final String matchId;
  const LiveMatchPage({Key? key, required this.matchId}) : super(key: key);

  @override
  State<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends State<LiveMatchPage> {
  late DateTime startTime;
  int quarter = 1;
  bool teamASelected = true;
  Player? selectedPlayer;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final matchModel = Provider.of<MatchModel>(context);

    final match = matchModel.get(widget.matchId);
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Match')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamAPlayers = match.teamAPlayers;
    final teamBPlayers = match.teamBPlayers;

    final players = teamASelected ? teamAPlayers : teamBPlayers;
    final selected = selectedPlayer;

    String scoreFor(List<Player> ps) {
      int goals = 0;
      int behinds = 0;
      for (var p in ps) {
        for (var a in p.actions) {
          if (a.type == ActionType.goal) goals++;
          if (a.type == ActionType.behind) behinds++;
        }
      }
      int total = goals * 6 + behinds;
      return '$goals.$behinds ($total)';
    }

    bool canRecord(Player player, ActionType type) {
      if (type == ActionType.goal) {
        if (player.actions.isEmpty) return false;
        return player.actions.last.type == ActionType.kick;
      }
      if (type == ActionType.behind) {
        if (player.actions.isEmpty) return false;
        return player.actions.last.type == ActionType.kick ||
            player.actions.last.type == ActionType.handball;
      }
      return true;
    }

    Future<void> record(ActionType type) async {
      if (selected == null) return;
      if (!canRecord(selected, type)) return;
      var action = PlayerAction(
        type: type,
        timestamp: DateTime.now().difference(startTime).inSeconds,
      );
      selected.actions.add(action);
      await matchModel.updateItem(match.id, match);
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quarter $quarter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(match.teamAName),
                Text(scoreFor(teamAPlayers)),
                const Text(' - '),
                Text(scoreFor(teamBPlayers)),
                Text(match.teamBName),
              ],
            ),
          ),
          ToggleButtons(
            isSelected: [teamASelected, !teamASelected],
            onPressed: (index) {
              setState(() {
                teamASelected = index == 0;
                selectedPlayer = null;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(match.teamAName),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(match.teamBName),
              ),
            ],
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: players.length,
              itemBuilder: (_, index) {
                var p = players[index];
                bool selectedFlag = p == selectedPlayer;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPlayer = p;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedFlag ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No.${p.number}'),
                        Text(p.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3,
              padding: const EdgeInsets.all(8),
              children: [
                _actionButton('Kick', () => record(ActionType.kick)),
                _actionButton('Handball', () => record(ActionType.handball)),
                _actionButton('Mark', () => record(ActionType.mark)),
                _actionButton('Tackle', () => record(ActionType.tackle)),
                _actionButton('Goal', () => record(ActionType.goal),
                    enabled: selected != null &&
                        canRecord(selected, ActionType.goal)),
                _actionButton('Behind', () => record(ActionType.behind),
                    enabled: selected != null &&
                        canRecord(selected, ActionType.behind)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    quarter++;
                  });
                },
                child: const Text('End Quarter'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('End Match'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        child: Text(label),
      ),
    );
  }
}

