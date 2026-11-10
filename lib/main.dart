import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/panier.dart';
import 'pages/produits_page.dart';

void main() {
  runApp(const BoutiqueApp());
}

class BoutiqueApp extends StatelessWidget {
  const BoutiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Panier(),
      child: MaterialApp(
        title: 'Boutique',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const ProduitsPage(),
      ),
    );
  }
}
