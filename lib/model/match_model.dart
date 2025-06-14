import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'afl_models.dart';

/// Provider model that stores and retrieves [MatchData] objects from
/// Firebase Firestore.
class MatchModel extends ChangeNotifier {
  final List<MatchData> items = [];

  CollectionReference matchesCollection =
      FirebaseFirestore.instance.collection('matches');
  bool loading = false;

  MatchModel() {
    fetch();
  }

  Future<String> add(MatchData item) async {
    loading = true;
    update();

    var doc = await matchesCollection.add(item.toMap());
    item.id = doc.id;
    items.add(item);

    loading = false;
    update();
    return doc.id;
  }

  Future updateItem(String id, MatchData item) async {
    loading = true;
    update();

    await matchesCollection.doc(id).update(item.toMap());

    var index = items.indexWhere((m) => m.id == id);
    if (index != -1) items[index] = item;

    loading = false;
    update();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await matchesCollection.doc(id).delete();

    items.removeWhere((m) => m.id == id);

    loading = false;
    update();
  }

  void update() {
    notifyListeners();
  }

  Future fetch() async {
    items.clear();

    loading = true;
    notifyListeners();

    var snapshot = await matchesCollection.orderBy('team_a_name').get();

    for (var doc in snapshot.docs) {
      var match = MatchData.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      items.add(match);
    }

    loading = false;
    update();
  }

  MatchData? get(String? id) {
    if (id == null) return null;
    try {
      return items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

