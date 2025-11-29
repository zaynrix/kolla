import 'package:go_router/go_router.dart';
import '../../views/home_page.dart';
import '../../views/actor/actor_page.dart';
import '../../views/workflow_manager/workflow_manager_page.dart';
import '../../views/all_boards/all_boards_page.dart';
import '../../views/reports/reports_page.dart';
import 'page_transitions.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const HomePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/actor/:actorId',
      pageBuilder: (context, state) {
        final actorId = state.pathParameters['actorId']!;
        return PageTransitions.slide(
          child: ActorPage(actorId: actorId),
          state: state,
          direction: 'right',
        );
      },
    ),
    GoRoute(
      path: '/workflow-manager',
      pageBuilder: (context, state) => PageTransitions.slide(
        child: const WorkflowManagerPage(),
        state: state,
        direction: 'left',
      ),
    ),
    GoRoute(
      path: '/all-boards',
      pageBuilder: (context, state) => PageTransitions.slide(
        child: const AllBoardsPage(),
        state: state,
        direction: 'left',
      ),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) => PageTransitions.slide(
        child: const ReportsPage(),
        state: state,
        direction: 'left',
      ),
    ),
  ],
);

