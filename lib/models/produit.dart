class Produit {
  final int id;
  final String nom;
  final double? prix;
  final String? description;

  /// Chemin de l'image renvoyé par Strapi, ex. "/uploads/xxx.jpg" (relatif),
  /// ou une URL complète. Null si le produit n'a pas d'image.
  final String? imagePath;

  /// Identifiant lisible de Strapi v5 (ex. "abc123xyz"), utilisé pour
  /// connecter une relation lors d'un POST. Null en Strapi v4.
  final String? documentId;

  Produit({
    required this.id,
    required this.nom,
    this.prix,
    this.description,
    this.imagePath,
    this.documentId,
  });

  /// Strapi v4 renvoie les champs dans "attributes", Strapi v5 les met à plat.
  /// Ce constructeur gère les deux cas.
  factory Produit.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] as Map<String, dynamic>? ?? json;

    String? champ(List<String> noms) {
      for (final n in noms) {
        final v = attrs[n];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    /// Un champ média Strapi ressemble à :
    ///  - v5 (image simple)  : { url: "/uploads/xxx.jpg", ... }
    ///  - v4 (image simple)  : { data: { attributes: { url: "..." } } }
    ///  - (multi-upload)     : la même chose mais avec "data" en liste
    String? extraireUrl(dynamic media) {
      if (media is Map && media['data'] != null) media = media['data'];
      if (media is List) {
        if (media.isEmpty) return null;
        media = media.first;
      }
      if (media is Map) {
        if (media['attributes'] is Map) media = media['attributes'];
        if (media['url'] != null) return media['url'].toString();
      }
      return null;
    }

    // Si ton champ média ne s'appelle pas "image", ajoute son nom ici.
    final imageBrut = attrs['image'] ?? attrs['photo'] ?? attrs['images'];

    return Produit(
      id: json['id'] as int,
      nom: champ(['nom', 'title', 'name']) ?? 'Sans nom',
      prix: champ(['prix', 'price']) == null
          ? null
          : double.tryParse(champ(['prix', 'price'])!),
      description: champ(['description', 'description_courte']),
      imagePath: extraireUrl(imageBrut),
      documentId: json['documentId']?.toString(),
    );
  }
}
