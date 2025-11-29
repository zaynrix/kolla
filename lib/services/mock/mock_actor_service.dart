import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../interfaces/i_actor_service.dart';
import '../../models/actor.dart';

class MockActorService implements IActorService {
  final _actorsSubject = BehaviorSubject<List<Actor>>.seeded([]);
  final List<Actor> _actors = [
    const Actor(
      id: 'actor-1',
      name: 'Yahya Abunada',
      role: 'Front End',
    ),
    const Actor(
      id: 'actor-2',
      name: 'Martin Krüger',
      role: 'Backend',
    ),
    const Actor(
      id: 'actor-3',
      name: 'Artem Paliesika',
      role: 'Backend',
    ),
    const Actor(
      id: 'actor-4',
      name: 'Marvin Tank',
      role: 'Front End',
    ),
    const Actor(
      id: 'actor-5',
      name: 'Albert Zacher',
      role: 'Backend',
    ),
  ];

  MockActorService() {
    _actorsSubject.add(_actors);
  }

  @override
  Future<List<Actor>> getAllActors() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _actors;
  }

  @override
  Future<Actor> getActor(String actorId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _actors.firstWhere((a) => a.id == actorId);
  }

  @override
  Stream<List<Actor>> watchAllActors() {
    return _actorsSubject.stream;
  }

  @override
  void dispose() {
    _actorsSubject.close();
  }
}

