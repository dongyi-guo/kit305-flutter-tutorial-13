import 'package:flutter/foundation.dart';

/// Types of actions that can be recorded for a player.
enum ActionType { kick, handball, mark, tackle, goal, behind }

/// Single action performed by a player during a match.
class PlayerAction {
  PlayerAction({required this.type, required this.timestamp, required this.quarter});

  ActionType type;
  int timestamp;
  int quarter;

  factory PlayerAction.fromMap(Map<String, dynamic> map) => PlayerAction(
        type: ActionType.values.firstWhere(
          (e) => describeEnum(e) == map['type'],
          orElse: () => ActionType.kick,
        ),
        timestamp: map['timestamp'] as int? ?? 0,
        quarter: map['quarter'] as int? ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'type': describeEnum(type),
        'timestamp': timestamp,
        'quarter': quarter,
      };
}

/// Representation of a player stored inside a match.
class Player {
  Player({required this.name, required this.number, this.image, List<PlayerAction>? actions})
      : actions = actions ?? [];

  String name;
  int number;
  String? image;
  List<PlayerAction> actions;

  factory Player.fromMap(Map<String, dynamic> map) => Player(
        name: map['name'] as String,
        number: (map['number'] ?? 0) as int,
        image: map['image'] as String?,
        actions: (map['actions'] as List<dynamic>? ?? [])
            .map((a) => PlayerAction.fromMap(a as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'number': number,
        'image': image,
        'actions': actions.map((a) => a.toMap()).toList(),
      };
}

/// Representation of a match containing players for both teams.
class MatchData {
  MatchData({required this.teamAName, required this.teamBName, List<Player>? teamAPlayers, List<Player>? teamBPlayers})
      : teamAPlayers = teamAPlayers ?? [],
        teamBPlayers = teamBPlayers ?? [];

  late String id;
  String teamAName;
  String teamBName;
  List<Player> teamAPlayers;
  List<Player> teamBPlayers;

  factory MatchData.fromMap(Map<String, dynamic> map, String id) => MatchData(
        teamAName: map['team_a_name'] as String,
        teamBName: map['team_b_name'] as String,
        teamAPlayers: (map['team_a_players'] as List<dynamic>? ?? [])
            .map((p) => Player.fromMap(p as Map<String, dynamic>))
            .toList(),
        teamBPlayers: (map['team_b_players'] as List<dynamic>? ?? [])
            .map((p) => Player.fromMap(p as Map<String, dynamic>))
            .toList(),
      )..id = id;

  Map<String, dynamic> toMap() => {
        'team_a_name': teamAName,
        'team_b_name': teamBName,
        'team_a_players': teamAPlayers.map((p) => p.toMap()).toList(),
        'team_b_players': teamBPlayers.map((p) => p.toMap()).toList(),
      };
}
