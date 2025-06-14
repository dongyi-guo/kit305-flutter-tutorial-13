import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/afl_models.dart';

class PlayerModel extends ChangeNotifier {
  final List<Player> items = [];

  CollectionReference playersCollection =
      FirebaseFirestore.instance.collection('players');
  bool loading = false;

  PlayerModel() {
    fetch();
  }

  Future<String> add(Player item) async {
    loading = true;
    update();

    var doc = await playersCollection.add(item.toMap());
    await fetch();
    return doc.id;
  }

  Future updateItem(String id, Player item) async {
    loading = true;
    update();

    await playersCollection.doc(id).update(item.toMap());
    await fetch();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await playersCollection.doc(id).delete();
    await fetch();
  }

  void update() {
    notifyListeners();
  }

  Future fetch() async {
    items.clear();

    loading = true;
    notifyListeners();

    var snapshot = await playersCollection.orderBy('name').get();

    for (var doc in snapshot.docs) {
      var player = Player.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      items.add(player);
    }

    loading = false;
    update();
  }

  Player? get(String? id) {
    if (id == null) return null;
    try {
      return items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
