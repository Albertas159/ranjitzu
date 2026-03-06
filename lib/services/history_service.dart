import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MatchResult {
  final String blueName;
  final String redName;
  final int blueScore;
  final int redScore;
  final String bluePrompt;
  final String redPrompt;
  final String belt;
  final bool isGi;
  final String promptType;
  final DateTime date;

  MatchResult({
    required this.blueName,
    required this.redName,
    required this.blueScore,
    required this.redScore,
    required this.bluePrompt,
    required this.redPrompt,
    required this.belt,
    required this.isGi,
    required this.promptType,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'blueName': blueName,
        'redName': redName,
        'blueScore': blueScore,
        'redScore': redScore,
        'bluePrompt': bluePrompt,
        'redPrompt': redPrompt,
        'belt': belt,
        'isGi': isGi,
        'promptType': promptType,
        'date': date.toIso8601String(),
      };

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        blueName: json['blueName'],
        redName: json['redName'],
        blueScore: json['blueScore'],
        redScore: json['redScore'],
        bluePrompt: json['bluePrompt'] ?? '',
        redPrompt: json['redPrompt'] ?? '',
        belt: json['belt'],
        isGi: json['isGi'],
        promptType: json['promptType'],
        date: DateTime.parse(json['date']),
      );
}

class HistoryService {
  static const _key = 'match_history';

  Future<List<MatchResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => MatchResult.fromJson(e)).toList();
  }

  Future<void> save(MatchResult match) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    existing.insert(0, match);
    prefs.setString(_key, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    existing.removeAt(index);
    prefs.setString(_key, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}