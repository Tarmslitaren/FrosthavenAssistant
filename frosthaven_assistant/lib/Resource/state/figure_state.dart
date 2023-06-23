import 'package:flutter/widgets.dart';
import '../enums.dart';

class FigureState {
  final health = ValueNotifier<int>(0);
  final level = ValueNotifier<int>(1);
  final maxHealth = ValueNotifier<int>(
      0); //? //needed for the times you wanna set hp yourself, for special reasons
  final conditions = ValueNotifier<List<Condition>>([]);
  final conditionsAddedThisTurn = ValueNotifier<Set<Condition>>({});
  final conditionsAddedPreviousTurn = ValueNotifier<Set<Condition>>({});
  final chill = ValueNotifier<int>(0);
}
