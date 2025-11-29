import '../../models/actor.dart';

abstract class IActorService {
  Future<List<Actor>> getAllActors();
  Future<Actor> getActor(String actorId);
  Stream<List<Actor>> watchAllActors();
  void dispose();
}

