import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand_illustration.dart';
import '../../../core/widgets/month_selector.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../auth/data/auth_repository.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../../households/presentation/household_switcher.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../onboarding/presentation/feature_tour.dart';
import '../../onboarding/presentation/feature_tours.dart';
import '../../../shared/selected_month_provider.dart';
import '../data/transaction_csv.dart';
import '../domain/transaction.dart';
import 'transactions_controller.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  /// Exporta las transacciones visibles (con los filtros aplicados) a CSV y
  /// abre la hoja de compartir.
  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final items =
        ref.read(filteredTransactionsProvider).valueOrNull ?? const [];
    if (items.isEmpty) {
      context.showError('No hay transacciones para exportar');
      return;
    }
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final month = ref.read(selectedMonthProvider);
    final csv = buildTransactionsCsv(
      items,
      categoryNames: {for (final c in categories) c.id: c.name},
      accountNames: {for (final a in accounts) a.id: a.name},
      authorNames: ref.read(householdMemberNamesProvider),
    );
    final label = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    try {
      await shareTransactionsCsv(
        csv: csv,
        fileName: 'astrea_transacciones_$label.csv',
      );
    } catch (_) {
      if (context.mounted) context.showError('No se pudo exportar el archivo');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTransactionsProvider);
    final filters = ref.watch(transactionFiltersProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final byId = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        actions: [
          IconButton(
            onPressed: () => _exportCsv(context, ref),
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportar CSV',
          ),
          const FeatureTourButton(tour: transactionsTour),
          const HouseholdIndicator(),
        ],
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
          const _SearchField(),
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
                    illustration: const BrandEmptyArt(EmptyArt.transactions),
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

/// Campo de búsqueda por texto (descripción, categoría o monto).
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(transactionFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si los filtros se limpian desde fuera (chip "Limpiar"), vacía el campo.
    ref.listen(transactionFiltersProvider, (_, next) {
      if (next.query.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    final query = ref.watch(
      transactionFiltersProvider.select((f) => f.query),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: ref.read(transactionFiltersProvider.notifier).setQuery,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por descripción, categoría o monto',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref
                        .read(transactionFiltersProvider.notifier)
                        .setQuery('');
                  },
                ),
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters});
  final TransactionFilters filters;

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(transactionFiltersProvider.notifier);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
      initialDateRange: filters.hasDateRange
          ? DateTimeRange(
              start: filters.from ?? filters.to!,
              end: filters.to ?? filters.from!,
            )
          : null,
    );
    if (picked != null) notifier.setDateRange(picked.start, picked.end);
  }

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
          FilterChip(
            avatar: filters.hasDateRange
                ? null
                : const Icon(Icons.date_range, size: 18),
            label: Text(
              filters.hasDateRange
                  ? '${Formatters.dayMonthYear(filters.from!)} – '
                      '${Formatters.dayMonthYear(filters.to!)}'
                  : 'Fechas',
            ),
            selected: filters.hasDateRange,
            onSelected: (_) => _pickDateRange(context, ref),
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

    // En presupuestos compartidos, etiqueta quién registró el movimiento.
    final shared = ref.watch(isSharedHouseholdProvider);
    final author = shared
        ? ref.watch(householdMemberNamesProvider)[tx.userId]
        : null;

    // Sólo el autor puede editar/eliminar (RLS Nivel A). En el personal todo es
    // tuyo; en compartido, los movimientos ajenos son de sólo lectura.
    final myId = ref.watch(currentUserProvider)?.id;
    final isMine = tx.userId == myId;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: isMine
            ? () => context.pushNamed(AppRoute.transactionForm.name, extra: tx)
            : null,
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
          '${Formatters.dayMonthYear(tx.date)}'
          '${tx.isInstallment ? ' · ${tx.installmentLabel}' : ''}'
          '${author != null ? ' · $author' : ''}',
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
