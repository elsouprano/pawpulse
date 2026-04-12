// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';
import '../core/utils/result.dart';

class PetState {
  final List<PetModel> petList;
  final PetModel? selectedPet;
  final bool isLoading;
  final String? error;

  PetState({
    this.petList = const [],
    this.selectedPet,
    this.isLoading = false,
    this.error,
  });

  PetState copyWith({
    List<PetModel>? petList,
    PetModel? selectedPet,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedPet = false,
  }) {
    return PetState(
      petList: petList ?? this.petList,
      selectedPet: clearSelectedPet ? null : (selectedPet ?? this.selectedPet),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PetProvider extends ValueNotifier<PetState> {
  final PetService _petService;
  StreamSubscription? _petSubscription;

  PetProvider(this._petService) : super(PetState());

  @override
  void dispose() {
    _petSubscription?.cancel();
    super.dispose();
  }

  void loadPets(String ownerId) {
    value = value.copyWith(isLoading: true, clearError: true);
    _petSubscription?.cancel();
    _petSubscription = _petService.getPetsByOwner(ownerId).listen(
      (pets) {
        value = value.copyWith(petList: pets, isLoading: false);
      },
      onError: (e) {
        value = value.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  void selectPet(PetModel pet) {
    value = value.copyWith(selectedPet: pet, clearError: true);
  }

  Future<void> addPet(PetModel pet) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _petService.addPet(pet);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> updatePet(PetModel pet) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _petService.updatePet(pet);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      if (value.selectedPet?.id == pet.id) {
        value = value.copyWith(selectedPet: pet, isLoading: false);
      } else {
        value = value.copyWith(isLoading: false);
      }
    }
  }

  Future<void> deletePet(String petId) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _petService.deletePet(petId);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(
        isLoading: false,
        clearSelectedPet: value.selectedPet?.id == petId,
      );
    }
  }
}
