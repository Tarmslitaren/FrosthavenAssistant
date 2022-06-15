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
    return _list.toString();
  }

  void init(List<E> list) {
    _list.addAll(list);
  }
  void shuffle() {
    _list.shuffle(Random());
  }
  void undoShuffle() { //mun djö!
    //TODO: how to undo and redo random stuff? I need to use a set random and somehow turn back time
    //so basically save whole list state for every command and overwrite instead of random shuffle

  }

  int size() {
    return _list.length;
  }

  List<E> getList(){ //TODO: try to return a copy for safety?
    return _list;
  }

  void setList(List<E> list) {
    _list.clear();
    _list.addAll(list);
  }
}