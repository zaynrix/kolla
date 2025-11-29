import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'services/interfaces/i_task_service.dart';
import 'services/interfaces/i_actor_service.dart';
import 'services/mock/mock_task_service.dart';
import 'services/mock/mock_actor_service.dart';

//..
void main() {
  runApp(const KollaApp());
}

class KollaApp extends StatelessWidget {
  const KollaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ITaskService>(
          create: (_) => MockTaskService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<IActorService>(
          create: (_) => MockActorService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Kolla - Task Management',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light, // Light theme only
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        // Modern page transitions
        builder: (context, child) {
          return AnimatedTheme(
            data: Theme.of(context),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
