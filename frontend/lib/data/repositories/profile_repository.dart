import 'package:ai_food_and_macro_tracker/data/models/targets.dart';
import 'package:ai_food_and_macro_tracker/data/models/user_profile.dart';
import 'package:ai_food_and_macro_tracker/logic/target_calculator.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<Targets?> getTargets();
  Future<void> saveTargets(Targets targets);
  Future<Targets> resetTargets();
}

class FakeProfileRepository implements ProfileRepository {
  UserProfile? _profile;
  Targets? _targets;

  FakeProfileRepository({bool initializeWithDefault = true}) {
    if (initializeWithDefault) {
      _profile = const UserProfile(
        id: 1,
        name: 'Alex',
        goal: 'maintain',
        age: 21,
        sex: 'male',
        heightCm: 175.0,
        weightKg: 70.0,
        activity: 'moderate',
        retentionMonths: 3,
        remindersOn: true,
        reminderTimes: ['13:30', '20:30'],
      );
      _targets = const Targets(
        id: 1,
        calories: 2600,
        proteinG: 126,
        carbsG: 361,
        fatG: 72,
        isCustom: false,
      );
    }
  }

  @override
  Future<UserProfile?> getProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    if (_targets == null || !_targets!.isCustom) {
      _targets = TargetCalculator.calculateTargets(profile);
    }
  }

  @override
  Future<Targets?> getTargets() async {
    return _targets;
  }

  @override
  Future<void> saveTargets(Targets targets) async {
    _targets = targets;
  }

  @override
  Future<Targets> resetTargets() async {
    if (_profile != null) {
      _targets = TargetCalculator.calculateTargets(_profile!);
    } else {
      _targets = const Targets(
        id: 1,
        calories: 2600,
        proteinG: 126,
        carbsG: 361,
        fatG: 72,
        isCustom: false,
      );
    }
    return _targets!;
  }
}
