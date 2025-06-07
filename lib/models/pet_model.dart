class Pet {
  String id;
  String name;
  String type;
  DateTime lastVaccination;
  DateTime nextVaccination;
  DateTime lastBath;
  DateTime nextBath;
  double estimatedCost;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.lastVaccination,
    required this.nextVaccination,
    required this.lastBath,
    required this.nextBath,
    this.estimatedCost = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'lastVaccination': lastVaccination.toIso8601String(),
      'nextVaccination': nextVaccination.toIso8601String(),
      'lastBath': lastBath.toIso8601String(),
      'nextBath': nextBath.toIso8601String(),
      'estimatedCost': estimatedCost,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      lastVaccination: DateTime.parse(json['lastVaccination']),
      nextVaccination: DateTime.parse(json['nextVaccination']),
      lastBath: DateTime.parse(json['lastBath']),
      nextBath: DateTime.parse(json['nextBath']),
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
    );
  }
}