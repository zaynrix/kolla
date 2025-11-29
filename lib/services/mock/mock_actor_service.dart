import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../interfaces/i_actor_service.dart';
import '../../models/actor.dart';

class MockActorService implements IActorService {
  final _actorsSubject = BehaviorSubject<List<Actor>>.seeded([]);
  final List<Actor> _actors = [
    const Actor(
      id: 'actor-1',
      name: 'Alice Johnson',
      role: 'Developer',
    ),
    const Actor(
      id: 'actor-2',
      name: 'Bob Smith',
      role: 'Designer',
    ),
    const Actor(
      id: 'actor-3',
      name: 'Carol Williams',
      role: 'QA Engineer',
    ),
    const Actor(
      id: 'actor-4',
      name: 'David Brown',
      role: 'DevOps',
    ),
    const Actor(
      id: 'actor-5',
      name: 'Eve Davis',
      role: 'Developer',
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

