import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/produit.dart';

class ApiService {
  /// Sur un émulateur Android, le localhost du PC s'appelle 10.0.2.2 :
  /// remplacer par 'http://10.0.2.2:1337' dans ce cas.
  static const String baseUrl = 'http://localhost:1337';

  /// Laisse vide si les produits sont publics dans Strapi,
  /// sinon colle ta clé API ici (Settings > API Tokens).
  static const String apiKey = '';

  /// Strapi renvoie les images avec un chemin relatif (/uploads/xxx.jpg).
  /// Cette méthode construit l'URL complète : sur émulateur Android, comme
  /// baseUrl vaut http://10.0.2.2:1337, l'image suit automatiquement.
  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  Future<List<Produit>> fetchProduits() async {
    final uri = Uri.parse('$baseUrl/api/produits?populate=*');
    final headers = <String, String>{
      if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    };

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Erreur ${res.statusCode} : ${res.body}');
    }

    final data = jsonDecode(res.body)['data'] as List;
    return data.map((e) => Produit.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Crée une entrée dans la collection "panier" de Strapi (POST /api/paniers).
  /// Champs attendus côté Strapi : titre (Texte), qte (Nombre),
  /// produit (relation vers "produit").
  ///
  /// La relation est connectée par documentId en Strapi v5, par id numérique
  /// en Strapi v4 — le modèle Produit fournit le bon automatiquement.
  Future<void> creerEntreePanier({
    required String titre,
    required int qte,
    required Produit produit,
  }) async {
    final uri = Uri.parse('$baseUrl/api/paniers');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'data': {
        'titre': titre,
        'qte': qte,
        'produit': produit.documentId ?? produit.id,
      },
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Strapi a répondu ${res.statusCode} : ${res.body}');
    }
  }
}
