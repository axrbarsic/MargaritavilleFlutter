import 'package:flutter/material.dart';

import '../features/work_session/presentation/work_session_shell.dart';
import 'margaritaville_theme.dart';

final class MargaritavilleApp extends StatelessWidget {
  const MargaritavilleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Margaritaville',
      theme: MargaritavilleTheme.dark,
      home: const WorkSessionShell(),
    );
  }
}
