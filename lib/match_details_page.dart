
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'model/afl_models.dart';
import 'model/match_model.dart';

class MatchDetailsPage extends StatelessWidget {
  final String matchId;
  const MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MatchModel>(context);
    final match = model.get(matchId);
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(child: Text('Match not found')),
      );
    }

    String scoreFor(List<Player> players, {int? quarter}) {
      int goals = 0;
      int behinds = 0;
      for (var p in players) {
        for (var a in p.actions) {
          if (quarter != null && a.quarter != quarter) continue;
          if (a.type == ActionType.goal) goals++;
          if (a.type == ActionType.behind) behinds++;
        }
      }
      int total = goals * 6 + behinds;
      return '$goals.$behinds ($total)';
    }

    List<Player> allPlayers(bool teamA) =>
        teamA ? match.teamAPlayers : match.teamBPlayers;

    Widget scoreTab() {
      List<TableRow> rows = [];
      for (int q = 1; q <= 4; q++) {
        rows.add(TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text('Q$q'),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(scoreFor(match.teamAPlayers, quarter: q)),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(scoreFor(match.teamBPlayers, quarter: q)),
          ),
        ]));
      }
      rows.add(TableRow(children: [
        const Padding(
          padding: EdgeInsets.all(4),
          child: Text('Final', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(scoreFor(match.teamAPlayers),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(scoreFor(match.teamBPlayers),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]));
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(decoration: BoxDecoration(color: Colors.grey.shade200),
              children: [
                const Padding(padding: EdgeInsets.all(4), child: Text('Quarter')),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(match.teamAName),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(match.teamBName),
                ),
              ]),
            ...rows
          ],
        ),
      );
    }

    Map<String, int> teamStats(bool teamA, {int? quarter}) {
      int kicks = 0, handballs = 0, marks = 0, tackles = 0, goals = 0, behinds = 0;
      for (var p in allPlayers(teamA)) {
        for (var a in p.actions) {
          if (quarter != null && a.quarter != quarter) continue;
          switch (a.type) {
            case ActionType.kick:
              kicks++;
              break;
            case ActionType.handball:
              handballs++;
              break;
            case ActionType.mark:
              marks++;
              break;
            case ActionType.tackle:
              tackles++;
              break;
            case ActionType.goal:
              goals++;
              break;
            case ActionType.behind:
              behinds++;
              break;
          }
        }
      }
      return {
        'disposals': kicks + handballs,
        'marks': marks,
        'tackles': tackles,
        'goals': goals,
        'behinds': behinds,
      };
    }

    Widget teamStatsTab() {
      int? selectedQuarter;
      TableRow buildRow(String label, int a, int b) {
        TextStyle styleA =
            TextStyle(fontWeight: a > b ? FontWeight.bold : FontWeight.normal);
        TextStyle styleB =
            TextStyle(fontWeight: b > a ? FontWeight.bold : FontWeight.normal);
        return TableRow(children: [
          Padding(padding: const EdgeInsets.all(4), child: Text(label)),
          Padding(padding: const EdgeInsets.all(4), child: Text('$a', style: styleA)),
          Padding(padding: const EdgeInsets.all(4), child: Text('$b', style: styleB)),
        ]);
      }

      return StatefulBuilder(builder: (context, setState) {
        var statsA = teamStats(true, quarter: selectedQuarter);
        var statsB = teamStats(false, quarter: selectedQuarter);
        List<TableRow> rows = [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              const Padding(padding: EdgeInsets.all(4), child: Text('Stat')),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(match.teamAName),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(match.teamBName),
              ),
            ],
          ),
          buildRow('Disposals', statsA['disposals']!, statsB['disposals']!),
          buildRow('Marks', statsA['marks']!, statsB['marks']!),
          buildRow('Tackles', statsA['tackles']!, statsB['tackles']!),
          buildRow('Score',
              statsA['goals']! * 6 + statsA['behinds']!,
              statsB['goals']! * 6 + statsB['behinds']!),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              DropdownButton<int?>(
                value: selectedQuarter,
                hint: const Text('Overall'),
                onChanged: (value) => setState(() => selectedQuarter = value),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Overall')),
                  for (var q = 1; q <= 4; q++)
                    DropdownMenuItem(value: q, child: Text('Quarter $q')),
                ],
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: rows,
              ),
            ],
          ),
        );
      });
    }

    Map<String, int> playerStats(Player p, {int? quarter}) {
      int kicks = 0, handballs = 0, marks = 0, tackles = 0, goals = 0, behinds = 0;
      for (var a in p.actions) {
        if (quarter != null && a.quarter != quarter) continue;
        switch (a.type) {
          case ActionType.kick:
            kicks++;
            break;
          case ActionType.handball:
            handballs++;
            break;
          case ActionType.mark:
            marks++;
            break;
          case ActionType.tackle:
            tackles++;
            break;
          case ActionType.goal:
            goals++;
            break;
          case ActionType.behind:
            behinds++;
            break;
        }
      }
      return {
        'disposals': kicks + handballs,
        'marks': marks,
        'tackles': tackles,
        'goals': goals,
        'behinds': behinds,
      };
    }

    Widget playerStatsTab() {
      Player? player;
      int? quarter;
      List<Player> players = [...match.teamAPlayers, ...match.teamBPlayers];
      return StatefulBuilder(builder: (context, setState) {
        var stats = player != null ? playerStats(player!, quarter: quarter) : null;
        Widget statRow(String label, int value) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [Expanded(child: Text(label)), Text('$value')],
              ),
            );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<Player>(
                value: player,
                hint: const Text('Select Player'),
                onChanged: (p) => setState(() => player = p),
                items: [for (var p in players) DropdownMenuItem(value: p, child: Text('${p.name} (No.${p.number})'))],
              ),
              DropdownButton<int?>(
                value: quarter,
                hint: const Text('Overall'),
                onChanged: (q) => setState(() => quarter = q),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Overall')),
                  for (var q = 1; q <= 4; q++) DropdownMenuItem(value: q, child: Text('Quarter $q')),
                ],
              ),
              if (stats != null) ...[
                statRow('Disposals', stats['disposals']!),
                statRow('Marks', stats['marks']!),
                statRow('Tackles', stats['tackles']!),
                statRow('Score', stats['goals']! * 6 + stats['behinds']!),
              ]
            ],
          ),
        );
      });
    }

    Widget comparePlayersTab() {
      Player? a;
      Player? b;
      int? quarter;
      List<Player> players = [...match.teamAPlayers, ...match.teamBPlayers];
      return StatefulBuilder(builder: (context, setState) {
        var statsA = a != null ? playerStats(a!, quarter: quarter) : null;
        var statsB = b != null ? playerStats(b!, quarter: quarter) : null;
        TextStyle style(int? va, int? vb) =>
            TextStyle(fontWeight: (va ?? 0) > (vb ?? 0) ? FontWeight.bold : FontWeight.normal);
        TableRow row(String label, int? va, int? vb) {
          return TableRow(children: [
            Padding(padding: const EdgeInsets.all(4), child: Text(label)),
            Padding(
                padding: const EdgeInsets.all(4),
                child: Text(va?.toString() ?? '-', style: style(va, vb))),
            Padding(
                padding: const EdgeInsets.all(4),
                child: Text(vb?.toString() ?? '-', style: style(vb, va))),
          ]);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              DropdownButton<Player>(
                value: a,
                hint: const Text('Player A'),
                onChanged: (v) => setState(() => a = v),
                items: [for (var p in players.where((p) => p != b)) DropdownMenuItem(value: p, child: Text('${p.name} (No.${p.number})'))],
              ),
              DropdownButton<Player>(
                value: b,
                hint: const Text('Player B'),
                onChanged: (v) => setState(() => b = v),
                items: [for (var p in players.where((p) => p != a)) DropdownMenuItem(value: p, child: Text('${p.name} (No.${p.number})'))],
              ),
              DropdownButton<int?>(
                value: quarter,
                hint: const Text('Overall'),
                onChanged: (q) => setState(() => quarter = q),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Overall')),
                  for (var q = 1; q <= 4; q++) DropdownMenuItem(value: q, child: Text('Quarter $q')),
                ],
              ),
              if (a != null && b != null) ...[
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: [
                        const Padding(padding: EdgeInsets.all(4), child: Text('Stat')),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(a!.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(b!.name),
                        ),
                      ],
                    ),
                    row('Disposals', statsA!['disposals'], statsB!['disposals']),
                    row('Marks', statsA['marks'], statsB['marks']),
                    row('Tackles', statsA['tackles'], statsB['tackles']),
                    row('Score',
                        statsA['goals']! * 6 + statsA['behinds']!,
                        statsB['goals']! * 6 + statsB['behinds']!),
                  ],
                ),
              ]
            ],
          ),
        );
      });
    }

    void share() {
      final buffer = StringBuffer();
      buffer.writeln('${match.teamAName} vs ${match.teamBName}');
      for (int q = 1; q <= 4; q++) {
        buffer.writeln(
            'Q$q: ${scoreFor(match.teamAPlayers, quarter: q)} - ${scoreFor(match.teamBPlayers, quarter: q)}');
      }
      buffer.writeln(
          'Final: ${scoreFor(match.teamAPlayers)} - ${scoreFor(match.teamBPlayers)}');
      Share.share(buffer.toString());
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Details'),
          actions: [IconButton(onPressed: share, icon: const Icon(Icons.share))],
          bottom: const TabBar(tabs: [
            Tab(text: 'Scores'),
            Tab(text: 'Team Stats'),
            Tab(text: 'Player Stats'),
            Tab(text: 'Compare Players'),
          ]),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: TabBarView(
          children: [
            scoreTab(),
            teamStatsTab(),
            playerStatsTab(),
            comparePlayersTab(),
          ],
        ),
      ),
    );
  }
}

