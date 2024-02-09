import 'dart:math';

//todo: make whole thing safe (only expose immutable values)

class CardStack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() {
    String retVal = "[";
    for (var item in _list) {
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
  }

  void shuffle() {
    _list.shuffle(Random());
  }

  int size() {
    return _list.length;
  }

  List<E> getList() {
    return _list.toList();
  }

  void remove(E card) {
    _list.remove(card);
  }

  E removeAt(int index) {
    return _list.removeAt(index);
  }

  void clear() {
    _list.clear();
  }

  void removeWhere(bool Function (E) test) {
    _list.removeWhere(test);
  }

  void add(E card) {
    _list.add(card);
  }

 // void insert(E card) {
 //   return _list.insert(card);
  //}

  void insert(int index, E card) {
    _list.insert(index, card);
  }

  void setList(List<E> list) {
    _list.clear();
    _list.addAll(list);
  }
}
