import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/afl_models.dart';
import 'model/match_model.dart';
import 'live_match_page.dart';

/// Displays a summary of the two teams before recording a match.
/// Users can discard the match or proceed to start recording.
class MatchBriefingPage extends StatelessWidget {
  final String matchId;

  const MatchBriefingPage({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchModel = Provider.of<MatchModel>(context);

    final match = matchModel.get(matchId);
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamAPlayers = match.teamAPlayers;
    final teamBPlayers = match.teamBPlayers;

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
            Expanded(child: _teamColumn(match.teamAName, teamAPlayers)),
            const SizedBox(width: 8),
            Expanded(child: _teamColumn(match.teamBName, teamBPlayers)),
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

