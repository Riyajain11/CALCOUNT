import 'dart:async';
import 'package:ai_food_and_macro_tracker/core/date_helpers.dart';
import 'package:ai_food_and_macro_tracker/data/models/daily_total.dart';
import 'package:ai_food_and_macro_tracker/data/models/food_item.dart';
import 'package:ai_food_and_macro_tracker/data/models/meal.dart';
import 'package:ai_food_and_macro_tracker/logic/totals_service.dart';

abstract class MealRepository {
  Future<void> saveMeal(Meal meal);
  Future<void> updateEntry(FoodItem item);
  Future<void> deleteEntry(String itemId);
  Future<void> deleteMeal(String mealId);
  Stream<List<Meal>> watchMealsForDate(String dateStr);
  Future<List<Meal>> getMealsForDate(String dateStr);
  Stream<List<DailyTotal>> watchDailyTotals(DateTime from, DateTime to);
  Future<List<Meal>> getAllMeals();
  Future<void> deleteOlderThan(String dateStr);
  Future<void> deleteAll();
}

class FakeMealRepository implements MealRepository {
  final _mealsController = StreamController<List<Meal>>.broadcast();
  final List<Meal> _meals = [];

  // Default to false so the user starts with 0 stats and empty history as expected in real usage!
  FakeMealRepository({bool seedSampleMeals = false}) {
    if (seedSampleMeals) {
      _seedSampleMeals();
    }
  }

  void _seedSampleMeals() {
    final today = DateHelpers.toLocalDayString(DateTime.now());
    final now = DateTime.now();

    final breakfast = Meal(
      id: 'meal_breakfast',
      entryDate: today,
      loggedAt: DateTime(now.year, now.month, now.day, 9, 15),
      mealType: 'breakfast',
      source: 'ai',
      provider: 'gemini',
      promptVersion: 'p1',
      confidence: 'high',
      items: [
        FoodItem(
          id: 'item_poha',
          name: 'Poha',
          portionLabel: '1 bowl',
          grams: 180.0,
          kcal: 320.0,
          proteinG: 9.0,
          carbsG: 58.0,
          fatG: 6.0,
          aiKcal: 320.0,
        ),
      ],
    );

    final lunch = Meal(
      id: 'meal_lunch',
      entryDate: today,
      loggedAt: DateTime(now.year, now.month, now.day, 13, 30),
      mealType: 'lunch',
      source: 'ai',
      provider: 'gemini',
      promptVersion: 'p1',
      confidence: 'medium',
      items: [
        FoodItem(
          id: 'item_dal_roti',
          name: 'Dal + 2 roti',
          portionLabel: '1 katori dal + 2 roti',
          grams: 230.0,
          kcal: 540.0,
          proteinG: 19.0,
          carbsG: 86.0,
          fatG: 14.0,
          aiKcal: 540.0,
        ),
      ],
    );

    _meals.addAll([breakfast, lunch]);
  }

  void _notify() {
    _mealsController.add(List.unmodifiable(_meals));
  }

  @override
  Future<void> saveMeal(Meal meal) async {
    _meals.removeWhere((m) => m.id == meal.id);
    _meals.add(meal);
    _notify();
  }

  @override
  Future<void> updateEntry(FoodItem item) async {
    for (int i = 0; i < _meals.length; i++) {
      final meal = _meals[i];
      final itemIndex = meal.items.indexWhere((it) => it.id == item.id);
      if (itemIndex != -1) {
        final updatedItems = List<FoodItem>.from(meal.items);
        updatedItems[itemIndex] = item;
        _meals[i] = meal.copyWith(items: updatedItems);
        _notify();
        return;
      }
    }
  }

  @override
  Future<void> deleteEntry(String itemId) async {
    for (int i = 0; i < _meals.length; i++) {
      final meal = _meals[i];
      final itemIndex = meal.items.indexWhere((it) => it.id == itemId);
      if (itemIndex != -1) {
        final updatedItems = List<FoodItem>.from(meal.items)..removeAt(itemIndex);
        if (updatedItems.isEmpty) {
          _meals.removeAt(i);
        } else {
          _meals[i] = meal.copyWith(items: updatedItems);
        }
        _notify();
        return;
      }
    }
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    _meals.removeWhere((m) => m.id == mealId);
    _notify();
  }

  @override
  Stream<List<Meal>> watchMealsForDate(String dateStr) async* {
    yield _meals.where((m) => m.entryDate == dateStr).toList();
    yield* _mealsController.stream.map(
      (list) => list.where((m) => m.entryDate == dateStr).toList(),
    );
  }

  @override
  Future<List<Meal>> getMealsForDate(String dateStr) async {
    return _meals.where((m) => m.entryDate == dateStr).toList();
  }

  @override
  Stream<List<DailyTotal>> watchDailyTotals(DateTime from, DateTime to) async* {
    yield TotalsService.computeRangeTotals(
      fromDate: from,
      toDate: to,
      allMeals: _meals,
    );
    yield* _mealsController.stream.map(
      (list) => TotalsService.computeRangeTotals(
        fromDate: from,
        toDate: to,
        allMeals: list,
      ),
    );
  }

  @override
  Future<List<Meal>> getAllMeals() async {
    return List.unmodifiable(_meals);
  }

  @override
  Future<void> deleteOlderThan(String dateStr) async {
    _meals.removeWhere((m) => m.entryDate.compareTo(dateStr) < 0);
    _notify();
  }

  @override
  Future<void> deleteAll() async {
    _meals.clear();
    _notify();
  }
}
