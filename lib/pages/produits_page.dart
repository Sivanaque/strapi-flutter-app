import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/panier.dart';
import '../models/produit.dart';
import '../services/api_service.dart';
import 'panier_page.dart';

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key});

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  late Future<List<Produit>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchProduits();
  }

  void _ajouterAuPanier(Produit produit) {
    context.read<Panier>().ajouter(produit);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produit.nom} ajouté au panier'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Enregistre aussi l'ajout dans la collection "panier" de Strapi.
    // L'ajout local réussit quand même si Strapi échoue : l'erreur est
    // signalée dans un SnackBar sans bloquer l'app.
    ApiService()
        .creerEntreePanier(titre: produit.nom, qte: 1, produit: produit)
        .catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Panier Strapi non enregistré : $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<Panier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          Badge(
            label: Text('${panier.nombreArticles}'),
            isLabelVisible: panier.nombreArticles > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PanierPage()),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Produit>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les produits :\n${snapshot.error}\n\n'
                  'Vérifie que Strapi tourne sur ${ApiService.baseUrl}.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final produits = snapshot.data ?? [];
          if (produits.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final f = ApiService().fetchProduits();
              setState(() => _future = f);
              await f;
            },
            child: ListView.builder(
              itemCount: produits.length,
              itemBuilder: (context, index) {
                final produit = produits[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: produit.imagePath == null
                          ? Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.image_outlined),
                              ),
                            )
                          : Image.network(
                              ApiService.imageUrl(produit.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  title: Text(produit.nom),
                  subtitle: produit.description == null
                      ? null
                      : Text(
                          produit.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (produit.prix != null)
                        Text('${produit.prix!.toStringAsFixed(2)} €'),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        tooltip: 'Ajouter au panier',
                        onPressed: () => _ajouterAuPanier(produit),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
