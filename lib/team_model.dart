import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'afl_models.dart';

class TeamModel extends ChangeNotifier {
  final List<Team> items = [];

  CollectionReference teamsCollection =
      FirebaseFirestore.instance.collection('teams');
  bool loading = false;

  TeamModel() {
    fetch();
  }

  Future<String> add(Team item) async {
    loading = true;
    update();

    var doc = await teamsCollection.add(item.toMap());
    await fetch();
    return doc.id;
  }

  Future updateItem(String id, Team item) async {
    loading = true;
    update();

    await teamsCollection.doc(id).update(item.toMap());
    await fetch();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await teamsCollection.doc(id).delete();
    await fetch();
  }

  void update() {
    notifyListeners();
  }

  Future fetch() async {
    items.clear();

    loading = true;
    notifyListeners();

    var snapshot = await teamsCollection.orderBy('name').get();

    for (var doc in snapshot.docs) {
      var team = Team.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      items.add(team);
    }

    loading = false;
    update();
  }

  Team? get(String? id) {
    return (id == null) ? null : items.firstWhere((t) => t.id == id);
  }
}
