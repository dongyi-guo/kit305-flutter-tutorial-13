// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['title', 'year', 'duration'],
  );
  return Movie(
    title: json['title'] as String,
    year: (json['year'] as num).toInt(),
    duration: json['duration'] as num,
    image: json['image'] as String?,
  );
}

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'title': instance.title,
      'year': instance.year,
      'duration': instance.duration,
      'image': instance.image,
    };
