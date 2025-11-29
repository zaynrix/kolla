import 'package:go_router/go_router.dart';
import '../../views/home_page.dart';
import '../../views/actor/actor_page.dart';
import '../../views/workflow_manager/workflow_manager_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/actor/:actorId',
      builder: (context, state) {
        final actorId = state.pathParameters['actorId']!;
        return ActorPage(actorId: actorId);
      },
    ),
    GoRoute(
      path: '/workflow-manager',
      builder: (context, state) => const WorkflowManagerPage(),
    ),
  ],
);

