import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/households/presentation/household_controller.dart';
import '../router/routes.dart';

/// Shell principal con barra de navegación inferior y FAB para registrar un
/// movimiento rápido. Usa [StatefulNavigationShell] de go_router para preservar
/// el estado de cada pestaña.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Dest(Icons.home_outlined, Icons.home, 'Inicio'),
    _Dest(Icons.receipt_long_outlined, Icons.receipt_long, 'Movimientos'),
    _Dest(Icons.account_balance_outlined, Icons.account_balance, 'Servicios'),
    _Dest(Icons.settings_outlined, Icons.settings, 'Ajustes'),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Volver a tocar la pestaña activa la lleva a su raíz.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final pendingInvites =
        ref.watch(receivedInvitationsProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      body: navigationShell,
      // El FAB sólo aparece en Inicio y Movimientos.
      floatingActionButton: (index == 0 || index == 1)
          ? FloatingActionButton(
              // Tag único: varios FAB coexisten en el IndexedStack del shell.
              heroTag: 'fab-shell',
              onPressed: () =>
                  context.pushNamed(AppRoute.transactionForm.name),
              tooltip: 'Registrar movimiento',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _goBranch,
        destinations: [
          for (var i = 0; i < _destinations.length; i++)
            NavigationDestination(
              // Badge en Ajustes (índice 3) si hay invitaciones pendientes.
              icon: i == 3 && pendingInvites > 0
                  ? Badge(
                      label: Text('$pendingInvites'),
                      child: Icon(_destinations[i].icon),
                    )
                  : Icon(_destinations[i].icon),
              selectedIcon: Icon(_destinations[i].selectedIcon),
              label: _destinations[i].label,
            ),
        ],
      ),
    );
  }
}

class _Dest {
  const _Dest(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
