import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/panier.dart';

class PanierPage extends StatelessWidget {
  const PanierPage({super.key});

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<Panier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          if (panier.lignes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vider le panier',
              onPressed: panier.vider,
            ),
        ],
      ),
      body: panier.lignes.isEmpty
          ? const Center(child: Text('Ton panier est vide.'))
          : ListView.builder(
              itemCount: panier.lignes.length,
              itemBuilder: (context, index) {
                final ligne = panier.lignes[index];
                return ListTile(
                  title: Text(ligne.produit.nom),
                  subtitle: Text('Quantité : ${ligne.quantite}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ligne.produit.prix != null)
                        Text(
                          '${(ligne.produit.prix! * ligne.quantite).toStringAsFixed(2)} €',
                        ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Retirer',
                        onPressed: () => panier.retirer(ligne.produit),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: panier.lignes.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18)),
                    Text(
                      '${panier.total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
