import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'afl_models.dart';
import 'match_model.dart';
import 'team_model.dart';
import 'player_model.dart';
import 'live_match_page.dart';

/// Displays a summary of the two teams before recording a match.
/// Users can discard the match or proceed to start recording.
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
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _teamColumn(teamA?.name ?? match.teamAId, teamAPlayers)),
            const SizedBox(width: 8),
            Expanded(child: _teamColumn(teamB?.name ?? match.teamBId, teamBPlayers)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await matchModel.delete(match.id);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Discard'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LiveMatchPage(matchId: match.id)),
                  );
                },
                child: const Text('Start Match'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _teamColumn(String name, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...players.map((p) => ListTile(
              dense: true,
              leading: p.image != null ? Image.memory(base64Decode(p.image!), width: 40) : null,
              title: Text(p.name),
              subtitle: Text('No. ${p.number}'),
            )),
      ],
    );
  }
}

