// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PetModel extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final double weight;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final String healthStatus;
  final DateTime? createdAt;
  final String? localImagePath;
  final List<String> photos;

  const PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.conditions,
    required this.allergies,
    required this.medications,
    required this.healthStatus,
    this.createdAt,
    this.localImagePath,
    this.photos = const [],
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PetModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0).toDouble(),
      conditions: List<String>.from(data['conditions'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      healthStatus: data['healthStatus'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      localImagePath: data['localImagePath'],
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'conditions': conditions,
      'allergies': allergies,
      'medications': medications,
      'healthStatus': healthStatus,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      'localImagePath': localImagePath,
      'photos': photos,
    };
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        species,
        breed,
        age,
        weight,
        conditions,
        allergies,
        medications,
        healthStatus,
        createdAt,
        localImagePath,
        photos,
      ];
}
