import 'package:flutter/material.dart';

import 'pages/pos_page.dart';

void main() {
  runApp(const AplikasiKasir());
}

class AplikasiKasir extends StatelessWidget {
  const AplikasiKasir({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const PosPage(),
    );
  }
}