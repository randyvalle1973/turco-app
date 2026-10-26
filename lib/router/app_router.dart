import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:turcoa_app/Screens/agenda_screen.dart';
import 'package:turcoa_app/Screens/cliente_screen.dart';
import 'package:turcoa_app/Screens/estilistas_screen.dart';
import 'package:turcoa_app/Screens/formulario_screen.dart';
import 'package:turcoa_app/Screens/turno_screen.dart';
import 'package:turcoa_app/screens/servicios_screen.dart';

import '../models/servicio.dart';
import '../models/turno.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/agenda',

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/agenda'),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Agenda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Clientes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.content_cut),
                  selectedIcon: Icon(Icons.content_cut),
                  label: 'Servicios',
                ),
                NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: 'Estilistas',
                ),
              ],
            ),
          );
        },

        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agenda',
                name: 'agenda',
                builder: (context, state) {
                  return AgendaScreen(
                    estilistaId: state.uri.queryParameters['estilista'],
                  );
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clientes',
                name: 'clientes',
                builder: (context, state) => const ClienteScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/servicios',
                name: 'servicios',
                builder: (context, state) => const ServiciosScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/estilistas',
                name: 'estilistas',
                builder: (context, state) => const EstilistasScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/turno/nuevo',
        name: 'turno-nuevo',
        builder: (context, state) {
          final extra = state.extra;

          return FormularioScreen(
            initialDate: extra is DateTime ? extra : null,
            turnoEditar: extra is Turno ? extra : null,
            servicioInicial: extra is Servicio ? extra : null,
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/formulario',
        name: 'formulario',
        builder: (context, state) {
          final extra = state.extra;

          return FormularioScreen(
            initialDate: extra is DateTime ? extra : null,
            turnoEditar: extra is Turno ? extra : null,
            servicioInicial: extra is Servicio ? extra : null,
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/turno/:id/editar',
        name: 'turno-editar',
        builder: (context, state) {
          final extra = state.extra;

          return FormularioScreen(turnoEditar: extra is Turno ? extra : null);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/turno/:id',
        name: 'turno-detalle',
        builder: (context, state) {
          return TurnoScreen(turnoId: state.pathParameters['id']);
        },
      ),

      GoRoute(
        path: '/turno',
        redirect: (context, state) {
          final id = state.uri.queryParameters['turnoId'];

          if (id == null || id.isEmpty) {
            return '/agenda';
          }

          return '/turno/${Uri.encodeComponent(id)}';
        },
      ),
    ],
  );
}
