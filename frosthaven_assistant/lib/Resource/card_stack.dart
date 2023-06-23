import 'dart:math';

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
    //TODO: try to return a copy for safety?
    return _list;
  }

  void setList(List<E> list) {
    _list.clear();
    _list.addAll(list);
  }
}
