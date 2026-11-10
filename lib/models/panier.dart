import 'package:flutter/foundation.dart';

import 'produit.dart';

class LignePanier {
  final Produit produit;
  int quantite;

  LignePanier({required this.produit, this.quantite = 1});
}

class Panier extends ChangeNotifier {
  final List<LignePanier> _lignes = [];

  List<LignePanier> get lignes => List.unmodifiable(_lignes);

  int get nombreArticles => _lignes.fold(0, (t, l) => t + l.quantite);

  double get total => _lignes.fold(
        0,
        (t, l) => t + (l.produit.prix ?? 0) * l.quantite,
      );

  void ajouter(Produit produit) {
    final index = _lignes.indexWhere((l) => l.produit.id == produit.id);
    if (index >= 0) {
      _lignes[index].quantite++;
    } else {
      _lignes.add(LignePanier(produit: produit));
    }
    notifyListeners();
  }

  void retirer(Produit produit) {
    _lignes.removeWhere((l) => l.produit.id == produit.id);
    notifyListeners();
  }

  void vider() {
    _lignes.clear();
    notifyListeners();
  }
}
