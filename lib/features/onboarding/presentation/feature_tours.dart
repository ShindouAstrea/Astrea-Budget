import 'package:flutter/material.dart';

import 'feature_tour.dart';

/// Tours por vista. El `id` es la clave de persistencia: no renombrar sin
/// querer que el tour vuelva a mostrarse a todos.

const transactionsTour = FeatureTour(
  id: 'transactions',
  slides: [
    TourSlide(
      icon: Icons.add_circle_outline,
      title: 'Registra en segundos',
      description: 'Con el botón + de la barra inferior anotas un gasto o '
          'ingreso: monto, categoría, cuenta y listo.',
    ),
    TourSlide(
      icon: Icons.filter_list,
      title: 'Filtra y revisa',
      description: 'Usa los chips para ver sólo gastos o ingresos y filtra '
          'por categoría. Toca un movimiento tuyo para editarlo o eliminarlo; '
          'los de otros miembros sólo se muestran.',
    ),
    TourSlide(
      icon: Icons.calendar_month_outlined,
      title: 'Tu mes financiero',
      description: 'El selector de mes agrupa los movimientos según tu ciclo '
          'de presupuesto. Puedes cambiar el día de inicio del mes en Ajustes.',
    ),
  ],
);

const servicesTour = FeatureTour(
  id: 'services',
  slides: [
    TourSlide(
      icon: Icons.receipt_long_outlined,
      title: 'Tus cuentas del mes',
      description: 'Agrega tus servicios fijos (arriendo, luz, internet, '
          'suscripciones) con monto estimado y día de cobro, o esporádicos '
          'para gastos que no se repiten.',
    ),
    TourSlide(
      icon: Icons.task_alt,
      title: 'Marca lo pagado',
      description: 'Los servicios fijos generan su pago de cada mes '
          'automáticamente. Al marcarlo como pagado se registra el gasto y '
          'el servicio queda al día.',
    ),
    TourSlide(
      icon: Icons.notifications_active_outlined,
      title: 'Que nada se venza',
      description: 'Activa los recordatorios en Ajustes y la app te avisará '
          'de los pagos pendientes desde 3 días antes del vencimiento.',
    ),
  ],
);

const budgetsTour = FeatureTour(
  id: 'budgets',
  slides: [
    TourSlide(
      icon: Icons.donut_small_outlined,
      title: 'Un tope por categoría',
      description: 'Define cuánto quieres gastar al mes en cada categoría '
          '(comida, ocio, transporte...). Toca una categoría para asignarle '
          'su tope.',
    ),
    TourSlide(
      icon: Icons.speed_outlined,
      title: 'Progreso a la vista',
      description: 'Las barras muestran cuánto llevas gastado del tope y '
          'cambian de color al acercarte al límite. También las ves en el '
          'inicio.',
    ),
    TourSlide(
      icon: Icons.admin_panel_settings_outlined,
      title: 'En compartido, decide el dueño',
      description: 'En un presupuesto compartido sólo el propietario define '
          'los topes; todos los miembros ven el avance.',
    ),
  ],
);

const savingsTour = FeatureTour(
  id: 'savings',
  slides: [
    TourSlide(
      icon: Icons.savings_outlined,
      title: 'Crea una meta',
      description: 'Ponle nombre, monto objetivo y, si quieres, una fecha '
          'límite: unas vacaciones, un fondo de emergencia, lo que sea.',
    ),
    TourSlide(
      icon: Icons.trending_up,
      title: 'Aporta a tu ritmo',
      description: 'Registra aportes (o retiros) cuando quieras y mira el '
          'progreso. En un presupuesto compartido todos pueden aportar a la '
          'misma meta.',
    ),
    TourSlide(
      icon: Icons.flag_outlined,
      title: 'Aporte sugerido',
      description: 'Si la meta tiene fecha objetivo, la app calcula cuánto '
          'te conviene ahorrar cada mes para llegar a tiempo.',
    ),
  ],
);

const trendsTour = FeatureTour(
  id: 'trends',
  slides: [
    TourSlide(
      icon: Icons.bar_chart_outlined,
      title: 'Seis meses de un vistazo',
      description: 'El gráfico compara tus ingresos y gastos de los últimos '
          '6 meses, agrupados según tu mes financiero.',
    ),
    TourSlide(
      icon: Icons.list_alt_outlined,
      title: 'Detalle por mes',
      description: 'Bajo el gráfico ves cada mes con su ingreso, gasto y '
          'balance, para detectar en qué mes se te fue la mano.',
    ),
    TourSlide(
      icon: Icons.compare_arrows_outlined,
      title: 'Comparación en el inicio',
      description: 'En la pantalla de inicio también ves cómo va tu gasto '
          'frente al mes anterior, con acceso directo a esta vista.',
    ),
  ],
);

const accountsTour = FeatureTour(
  id: 'accounts',
  slides: [
    TourSlide(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Todas tus cuentas',
      description: 'Crea cuentas de efectivo, débito, crédito o ahorro. Cada '
          'movimiento se asocia a una cuenta y aquí ves su saldo actualizado.',
    ),
    TourSlide(
      icon: Icons.swap_horiz,
      title: 'Transfiere entre cuentas',
      description: 'Con el botón de transferir mueves plata de una cuenta a '
          'otra sin que cuente como gasto ni ingreso en tu resumen.',
    ),
    TourSlide(
      icon: Icons.credit_card_outlined,
      title: 'Tarjetas de crédito',
      description: 'Para las cuentas de crédito puedes registrar el cupo y '
          'los días de facturación y pago, y así controlar cuánto llevas '
          'usado.',
    ),
  ],
);
