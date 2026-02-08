import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/people/people_list_screen.dart';
import '../screens/people/person_detail_screen.dart';
import '../screens/people/person_form_screen.dart';
import '../screens/people/import_contacts_screen.dart';
import '../screens/gifts/gift_review_screen.dart';
import '../screens/gifts/gift_results_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isLoading) return null;
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/people',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: PeopleListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, _) => const PersonFormScreen(),
              ),
              GoRoute(
                path: 'import',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, _) => const ImportContactsScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) => PersonDetailScreen(
                  personId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => PersonFormScreen(
                      personId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'gifts',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => GiftReviewScreen(
                      personId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'results',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, state) => GiftResultsScreen(
                          personId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
