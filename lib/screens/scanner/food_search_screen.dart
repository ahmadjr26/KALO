import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../providers/app_state_provider.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final List<MealIngredient> _database = const [
    MealIngredient(
      id: 'db-1',
      name: 'Boneless Skinless Chicken Breast',
      massGrams: 150,
      displayQuantity: 1,
      displayUnit: 'breast',
      calories: 248,
      proteinG: 46.5,
      carbsG: 0,
      fatG: 5.4,
    ),
    MealIngredient(
      id: 'db-2',
      name: 'Hass Avocado (Fresh)',
      massGrams: 100,
      displayQuantity: 0.5,
      displayUnit: 'avocado',
      calories: 160,
      proteinG: 2,
      carbsG: 8.5,
      fatG: 14.7,
      fiberG: 6.7,
    ),
    MealIngredient(
      id: 'db-3',
      name: 'Cooked Jasmine Rice',
      massGrams: 150,
      displayQuantity: 1,
      displayUnit: 'cup',
      calories: 195,
      proteinG: 4,
      carbsG: 43,
      fatG: 0.4,
    ),
    MealIngredient(
      id: 'db-4',
      name: 'Whole Large Egg (Boiled/Poached)',
      massGrams: 50,
      displayQuantity: 1,
      displayUnit: 'egg',
      calories: 72,
      proteinG: 6.3,
      carbsG: 0.4,
      fatG: 4.8,
    ),
    MealIngredient(
      id: 'db-5',
      name: 'Whey Protein Isolate Powder',
      massGrams: 30,
      displayQuantity: 1,
      displayUnit: 'scoop',
      calories: 120,
      proteinG: 25,
      carbsG: 2,
      fatG: 1,
    ),
    MealIngredient(
      id: 'db-6',
      name: 'Rolled Oats (Dry)',
      massGrams: 50,
      displayQuantity: 0.5,
      displayUnit: 'cup',
      calories: 190,
      proteinG: 6.5,
      carbsG: 34,
      fatG: 3,
      fiberG: 5,
    ),
    MealIngredient(
      id: 'db-7',
      name: 'Atlantic Salmon Fillet',
      massGrams: 180,
      displayQuantity: 1,
      displayUnit: 'fillet',
      calories: 360,
      proteinG: 38,
      carbsG: 0,
      fatG: 22,
    ),
  ];

  void _addFoodItem(MealIngredient item) {
    const uuid = Uuid();
    final newMeal = Meal(
      id: uuid.v4(),
      dishName: item.name,
      mealType: MealType.snack,
      sourceType: MealSource.manual,
      loggedAt: DateTime.now(),
      healthScore: 9,
      ingredients: [item],
    );

    ref.read(appStateProvider.notifier).addMeal(newMeal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Text('Added ${item.name} to log'),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _database.where((item) {
      return item.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Food Database',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _query = val),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textMuted),
                    hintText: 'Search foods (e.g. Chicken, Rice, Eggs)...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '1 ${item.displayUnit} (${item.massGrams.toInt()}g) • P: ${item.proteinG}g C: ${item.carbsG}g F: ${item.fatG}g',
                                    style: AppTypography.xs,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item.calories.toInt()} kcal',
                              style: AppTypography.sm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _addFoodItem(item),
                              icon: const Icon(Icons.add_circle, color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
