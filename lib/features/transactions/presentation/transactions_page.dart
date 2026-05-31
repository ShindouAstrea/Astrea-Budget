import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/month_selector.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_controller.dart';
import '../domain/transaction.dart';
import 'transactions_controller.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTransactionsProvider);
    final filters = ref.watch(transactionFiltersProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final byId = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: const MonthSelector(),
          ),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(filters: filters),
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(
                message: 'No pudimos cargar las transacciones.',
                onRetry: () => ref.invalidate(monthlyTransactionsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: filters.isActive
                        ? 'Sin resultados'
                        : 'Sin movimientos este mes',
                    message: filters.isActive
                        ? 'Prueba ajustando los filtros.'
                        : 'Registra tu primer ingreso o gasto con el botón +.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(monthlyTransactionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _TransactionTile(
                      tx: items[i],
                      category: byId[items[i].categoryId],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters});
  final TransactionFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFiltersProvider.notifier);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Ingresos'),
            selected: filters.type == TransactionType.income,
            onSelected: (sel) =>
                notifier.setType(sel ? TransactionType.income : null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Gastos'),
            selected: filters.type == TransactionType.expense,
            onSelected: (sel) =>
                notifier.setType(sel ? TransactionType.expense : null),
          ),
          const SizedBox(width: 8),
          DropdownMenu<String?>(
            initialSelection: filters.categoryId,
            hintText: 'Categoría',
            onSelected: notifier.setCategory,
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: null, label: 'Todas'),
              for (final c in categories)
                DropdownMenuEntry(value: c.id, label: c.name),
            ],
          ),
          if (filters.isActive) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Limpiar'),
              onPressed: notifier.clear,
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.tx, required this.category});

  final TransactionModel tx;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = context.finance;
    final color = tx.isIncome ? finance.income : finance.expense;
    final catColor = category?.colorValue ?? AppColors.brand;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => context.pushNamed(
          AppRoute.transactionForm.name,
          extra: tx,
        ),
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.15),
          child: Icon(category?.iconData ?? Icons.category, color: catColor),
        ),
        title: Text(
          tx.description?.isNotEmpty == true
              ? tx.description!
              : (category?.name ?? 'Sin categoría'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${category?.name ?? 'Sin categoría'} · '
          '${Formatters.dayMonthYear(tx.date)}',
        ),
        trailing: Text(
          Formatters.signedCurrency(tx.amount, isIncome: tx.isIncome),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
