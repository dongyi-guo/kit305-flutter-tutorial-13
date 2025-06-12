import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'afl_models.dart';
import 'match_model.dart';
import 'team_model.dart';
import 'player_model.dart';

/// Displays the teams and players for a match before it starts.
/// Users can go back or start the match, which simply marks the
/// match as started in Firestore for now.
class MatchBriefingPage extends StatelessWidget {
  final String matchId;

  const MatchBriefingPage({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchModel = Provider.of<MatchModel>(context);
    final teamModel = Provider.of<TeamModel>(context);
    final playerModel = Provider.of<PlayerModel>(context);

    final match = matchModel.get(matchId);
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamA = teamModel.get(match.teamAId);
    final teamB = teamModel.get(match.teamBId);

    final teamAPlayers = teamA == null
        ? <Player>[]
        : playerModel.items
            .where((p) => teamA.players.contains(p.id))
            .toList();
    final teamBPlayers = teamB == null
        ? <Player>[]
        : playerModel.items
            .where((p) => teamB.players.contains(p.id))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Briefing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text('Team A: ${teamA?.name ?? match.teamAId}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...teamAPlayers.map((p) => ListTile(
                leading: p.image != null
                    ? Image.file(File(p.image!), width: 40)
                    : null,
                title: Text(p.name),
                subtitle: Text('No. ${p.number}'),
              )),
          const SizedBox(height: 10),
          Text('Team B: ${teamB?.name ?? match.teamBId}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...teamBPlayers.map((p) => ListTile(
                leading: p.image != null
                    ? Image.file(File(p.image!), width: 40)
                    : null,
                title: Text(p.name),
                subtitle: Text('No. ${p.number}'),
              )),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 8),
            if (!match.started)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    match.started = true;
                    await matchModel.updateItem(match.id, match);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Start Match'),
                ),
              )
          ],
        ),
      ),
    );
  }
}

