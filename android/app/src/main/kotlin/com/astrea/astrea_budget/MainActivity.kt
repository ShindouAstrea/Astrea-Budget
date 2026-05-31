package com.astrea.astrea_budget

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth requiere FlutterFragmentActivity (no FlutterActivity) para poder
// mostrar el prompt de biometría; de lo contrario lanza "no_fragment_activity".
class MainActivity : FlutterFragmentActivity()
