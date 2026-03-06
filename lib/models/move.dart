const beltOrder = ['white', 'blue', 'purple', 'brown', 'black'];

class Submission {
  final String id;
  final String name;
  final String minBelt;
  final bool gi;
  final bool nogi;
  final List<String> tags;
  final String description;
  final String? demoUrl;

  Submission({
    required this.id,
    required this.name,
    required this.minBelt,
    required this.gi,
    required this.nogi,
    required this.tags,
    required this.description,
    this.demoUrl,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      name: json['name'],
      minBelt: json['min_belt'],
      gi: json['gi'] ?? false,
      nogi: json['nogi'] ?? false,
      tags: List<String>.from(json['tags']),
      description: json['description'],
      demoUrl: json['demo_url'],
    );
  }
}

class PositionPair {
  final String id;
  final String name;
  final String minBelt;
  final bool symmetric;
  final String blueRole;
  final String redRole;
  final bool gi;
  final bool nogi;
  final List<String> tags;
  final String? demoUrl;

  PositionPair({
    required this.id,
    required this.name,
    required this.minBelt,
    required this.symmetric,
    required this.blueRole,
    required this.redRole,
    required this.gi,
    required this.nogi,
    required this.tags,
    this.demoUrl,
  });

  factory PositionPair.fromJson(Map<String, dynamic> json) {
    return PositionPair(
      id: json['id'],
      name: json['name'],
      minBelt: json['min_belt'],
      symmetric: json['symmetric'],
      blueRole: json['blue_role'],
      redRole: json['red_role'],
      gi: json['gi'] ?? false,
      nogi: json['nogi'] ?? false,
      tags: List<String>.from(json['tags']),
      demoUrl: json['demo_url'],
    );
  }
}

bool isBeltEligible(String minBelt, String selectedBelt) {
  final minIndex = beltOrder.indexOf(minBelt);
  final selectedIndex = beltOrder.indexOf(selectedBelt);
  return selectedIndex >= minIndex;
}