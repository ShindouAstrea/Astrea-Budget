import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';

/// Shell principal con barra de navegación inferior y FAB para registrar un
/// movimiento rápido. Usa [StatefulNavigationShell] de go_router para preservar
/// el estado de cada pestaña.
class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      // El FAB sólo aparece en Inicio y Movimientos.
      floatingActionButton: (index == 0 || index == 1)
          ? FloatingActionButton(
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
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
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
