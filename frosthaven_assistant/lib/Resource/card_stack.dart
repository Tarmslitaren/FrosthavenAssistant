import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

//todo: make whole thing safe (only expose immutable values)

class CardStack<E> extends ChangeNotifier {
  final _list = <E>[];

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  void push(E value) {
    _list.add(value);
    notifyListeners();
  }

  E pop() {
    final value = _list.removeLast();
    notifyListeners();
    return value;
  }

  @override
  String toString() {
    String retVal = "[";
    for (final item in _list) {
      retVal += "${item.toString()},";
    }
    if (_list.isNotEmpty) {
      retVal = retVal.substring(0, retVal.length - 1);
    }
    retVal += "]";
    return retVal;
  }

  void init(List<E> list) {
    _list.addAll(list);
    notifyListeners();
  }

  void shuffle() {
    _list.shuffle(Random());
    notifyListeners();
  }

  int size() {
    return _list.length;
  }

  List<E> getList() {
    return _list.toList();
  }

  void remove(E card) {
    _list.remove(card);
    notifyListeners();
  }

  E removeAt(int index) {
    final value = _list.removeAt(index);
    notifyListeners();
    return value;
  }

  void clear() {
    _list.clear();
    notifyListeners();
  }

  void removeWhere(bool Function(E) test) {
    _list.removeWhere(test);
    notifyListeners();
  }

  void removeFirstWhere(bool Function(E) test) {
    final object = _list.firstWhereOrNull(test);
    if (object != null) {
      _list.remove(object);
      notifyListeners();
    }
  }

  void add(E card) {
    _list.add(card);
    notifyListeners();
  }

  void insert(int index, E card) {
    _list.insert(index, card);
    notifyListeners();
  }

  void setList(List<E> list) {
    _list.clear();
    _list.addAll(list);
    notifyListeners();
  }
}
