import 'package:flutter/foundation.dart';

/// Types of actions that can be recorded for a player.
enum ActionType { kick, handball, mark, tackle, goal, behind }

/// Single action performed by a player during a match.
class PlayerAction {
  PlayerAction({required this.type, required this.timestamp});

  ActionType type;
  int timestamp;

  factory PlayerAction.fromMap(Map<String, dynamic> map) => PlayerAction(
        type: ActionType.values.firstWhere(
          (e) => describeEnum(e) == map['type'],
          orElse: () => ActionType.kick,
        ),
        timestamp: map['timestamp'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'type': describeEnum(type),
        'timestamp': timestamp,
      };
}

/// Representation of a player.
class Player {
  Player({required this.name, required this.number, this.image, List<PlayerAction>? actions})
      : actions = actions ?? [];

  late String id;
  String name;
  int number;
  String? image;
  List<PlayerAction> actions;

  Player.fromMap(Map<String, dynamic> map, this.id)
      : name = map['name'] as String,
        number = (map['number'] ?? 0) as int,
        image = map['image'] as String?,
        actions = (map['actions'] as List<dynamic>? ?? [])
            .map((a) => PlayerAction.fromMap(a as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toMap() => {
        'name': name,
        'number': number,
        'image': image,
        'actions': actions.map((a) => a.toMap()).toList(),
      };
}

/// Representation of a team consisting of player ids.
class Team {
  Team({required this.name, List<String>? players}) : players = players ?? [];

  late String id;
  String name;
  List<String> players;

  Team.fromMap(Map<String, dynamic> map, this.id)
      : name = map['name'] as String,
        players = List<String>.from(map['players'] ?? const []);

  Map<String, dynamic> toMap() => {
        'name': name,
        'players': players,
      };
}

/// Representation of a match containing ids of the two teams.
class MatchData {
  MatchData({required this.teamAId, required this.teamBId, this.started = false});

  late String id;
  String teamAId;
  String teamBId;
  bool started;

  MatchData.fromMap(Map<String, dynamic> map, this.id)
      : teamAId = map['team_a'] as String,
        teamBId = map['team_b'] as String,
        started = map['started'] as bool? ?? false;

  Map<String, dynamic> toMap() => {
        'team_a': teamAId,
        'team_b': teamBId,
        'started': started,
      };
}
