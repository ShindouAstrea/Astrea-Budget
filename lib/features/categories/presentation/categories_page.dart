import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../domain/category.dart';
import 'categories_controller.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar las categorías.',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyStateView(
              icon: Icons.category_outlined,
              title: 'Sin categorías',
              message: 'Crea tu primera categoría con el botón +.',
            );
          }
          final income =
              categories.where((c) => c.type == TransactionType.income).toList();
          final expense =
              categories.where((c) => c.type == TransactionType.expense).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _Section(title: 'Ingresos', items: income, onTap: (c) => _openForm(context, ref, category: c)),
              const SizedBox(height: 16),
              _Section(title: 'Gastos', items: expense, onTap: (c) => _openForm(context, ref, category: c)),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, {Category? category}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CategoryFormSheet(category: category),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, required this.onTap});

  final String title;
  final List<Category> items;
  final ValueChanged<Category> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Sin categorías de $title.'.toLowerCase(),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in items)
                ActionChip(
                  avatar: Icon(c.iconData, size: 18, color: c.colorValue),
                  label: Text(c.name),
                  onPressed: () => onTap(c),
                ),
            ],
          ),
      ],
    );
  }
}

/// Hoja inferior para crear/editar una categoría.
class _CategoryFormSheet extends ConsumerStatefulWidget {
  const _CategoryFormSheet({this.category});
  final Category? category;

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late TransactionType _type;
  late String _icon;
  late String _color;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  static const _palette = [
    '#2563EB', '#16A34A', '#DC2626', '#F97316',
    '#8B5CF6', '#14B8A6', '#EAB308', '#EC4899',
    '#0EA5E9', '#64748B',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = TextEditingController(text: c?.name ?? '');
    _type = c?.type ?? TransactionType.expense;
    _icon = c?.icon ?? 'category';
    _color = c?.color ?? _palette.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notifier = ref.read(categoriesProvider.notifier);
    try {
      if (_isEditing) {
        await notifier.edit(widget.category!.copyWith(
          name: _name.text.trim(),
          type: _type,
          icon: _icon,
          color: _color,
        ));
      } else {
        await notifier.add(
          name: _name.text.trim(),
          type: _type,
          icon: _icon,
          color: _color,
        );
      }
      if (mounted) {
        context.showSuccess('Categoría guardada');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    await ref.read(categoriesProvider.notifier).remove(widget.category!.id);
    if (mounted) {
      context.showSuccess('Categoría eliminada');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Editar categoría' : 'Nueva categoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => Validators.required(v, field: 'El nombre'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Gasto')),
                ButtonSegment(value: TransactionType.income, label: Text('Ingreso')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.fromHex(hex),
                        shape: BoxShape.circle,
                        border: _color == hex
                            ? Border.all(width: 3, color: Theme.of(context).colorScheme.onSurface)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ícono', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in kCategoryIcons.entries)
                  GestureDetector(
                    onTap: () => setState(() => _icon = entry.key),
                    child: CircleAvatar(
                      backgroundColor: _icon == entry.key
                          ? AppColors.fromHex(_color)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        entry.value,
                        color: _icon == entry.key
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Guardar' : 'Crear'),
            ),
            if (_isEditing)
              TextButton(
                onPressed: _saving ? null : _delete,
                child: Text(
                  'Eliminar categoría',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
