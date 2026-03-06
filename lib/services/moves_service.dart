import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/move.dart';

class MovesService {
  List<Submission> _submissions = [];
  List<PositionPair> _positionPairs = [];
  final Random _random = Random();
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final String data = await rootBundle.loadString('assets/moves.json');
    final Map<String, dynamic> json = jsonDecode(data);
    _submissions = (json['submissions'] as List)
        .map((e) => Submission.fromJson(e))
        .toList();
    _positionPairs = (json['position_pairs'] as List)
        .map((e) => PositionPair.fromJson(e))
        .toList();
    _loaded = true;
  }

  List<Submission> _eligibleSubs(String belt, bool isGi) {
    return _submissions.where((s) {
      if (!isBeltEligible(s.minBelt, belt)) return false;
      return isGi ? s.gi : s.nogi;
    }).toList();
  }

  List<PositionPair> _eligiblePos(String belt, bool isGi) {
    return _positionPairs.where((p) {
      if (!isBeltEligible(p.minBelt, belt)) return false;
      return isGi ? p.gi : p.nogi;
    }).toList();
  }

  Submission? randomSubmission(String belt, bool isGi) {
    final eligible = _eligibleSubs(belt, isGi);
    if (eligible.isEmpty) return null;
    return eligible[_random.nextInt(eligible.length)];
  }

  List<Submission?> randomSubmissionPair(String belt, bool isGi) {
    final eligible = _eligibleSubs(belt, isGi);
    if (eligible.isEmpty) return [null, null];
    if (eligible.length == 1) return [eligible[0], eligible[0]];
    final first = eligible[_random.nextInt(eligible.length)];
    Submission second;
    do {
      second = eligible[_random.nextInt(eligible.length)];
    } while (second.id == first.id);
    return [first, second];
  }

  PositionPair? randomPositionPair(String belt, bool isGi) {
    final eligible = _eligiblePos(belt, isGi);
    if (eligible.isEmpty) return null;
    return eligible[_random.nextInt(eligible.length)];
  }

  int randomRoundTime() => _random.nextInt(10) + 1;
}