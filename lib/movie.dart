import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'movie.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Movie
{
  late String id;
  @JsonKey(required: true)
  String title;
  @JsonKey(required: true)
  int year;
  @JsonKey(required: true)
  num duration;
  String? image;

  Movie({required this.title, required this.year, required this.duration, this.image});

  // Movie.fromJson(Map<String, dynamic> json, this.id)
  //     : title = json['title'],
  //       year = json['year'],
  //       duration = json['duration'];
  //
  // Map<String, dynamic> toJson() => {
  //       'title': title,
  //       'year': year,
  //       'duration': duration,
  //     };

  // Use json_serializable
  factory Movie.fromJson(Map<String, dynamic> json, String id) {
    final movie = _$MovieFromJson(json);
    movie.id = id;
    return movie;
  }
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}

class MovieModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Movie> items = [];

  CollectionReference moviesCollection = FirebaseFirestore.instance.collection('movies');
  bool loading = false;

  //Normally a model would get from a database here, we are just hardcoding some data for this week
  MovieModel() { fetch(); }

  Future add(Movie item) async{
    loading = true;
    update();

    await moviesCollection.add(item.toJson());
    await fetch();
  }

  Future updateItem(String id, Movie item) async{
    loading = true;
    update();

    await moviesCollection.doc(id).update(item.toJson());
    await fetch();
  }

  Future delete(String id) async{
    loading = true;
    update();

    await moviesCollection.doc(id).delete();
    await fetch();
  }

  // This call tells the widgets that are listening to this model to rebuild.
  void update()
  {
    notifyListeners();
  }

  Future fetch() async {
    items.clear();

    loading = true;
    notifyListeners();

    var snapshot = await moviesCollection.orderBy("title").get();

    for (var doc in snapshot.docs) {
      var movie = Movie.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      items.add(movie);
    }

    await Future.delayed(const Duration(seconds: 2));

    loading = false;
    update();
  }

  Movie? get(String? id){
    if(id == null) return null;
    try {
      return items.firstWhere((movie) => movie.id == id);
    } catch(_) {
      return null;
    }
  }
}
