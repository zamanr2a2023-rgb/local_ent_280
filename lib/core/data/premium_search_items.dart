/// Dummy destinations/services for premium home search.
class PremiumSearchItem {
  const PremiumSearchItem({
    required this.title,
    required this.subtitle,
    required this.keywords,
  });

  final String title;
  final String subtitle;
  final List<String> keywords;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    if (title.toLowerCase().contains(q)) return true;
    if (subtitle.toLowerCase().contains(q)) return true;
    return keywords.any((k) => k.contains(q));
  }
}

abstract final class PremiumSearchItems {
  static const List<PremiumSearchItem> all = [
    PremiumSearchItem(
      title: 'Tesla Model 3 Performance',
      subtitle: 'Aluguer Premium • Aeroporto de Lisboa',
      keywords: ['tesla', 'model', 'performance', 'aluguer', 'carro', 'elétrico'],
    ),
    PremiumSearchItem(
      title: 'Aeroporto de Lisboa (LIS)',
      subtitle: 'Levantamento e devolução de viatura',
      keywords: ['lisboa', 'aeroporto', 'lis', 'levantamento', 'devolução'],
    ),
    PremiumSearchItem(
      title: 'Aluguer de Viatura',
      subtitle: 'Revisão de reserva • 5 dias',
      keywords: ['aluguer', 'viatura', 'reserva', 'rental', 'carro'],
    ),
    PremiumSearchItem(
      title: 'Porto — Estação de Campanhã',
      subtitle: 'Destino e serviços de mobilidade',
      keywords: ['porto', 'campanhã', 'comboio', 'destino'],
    ),
    PremiumSearchItem(
      title: 'Entregas Rápidas',
      subtitle: 'Mercearia e Farmácia',
      keywords: ['entrega', 'mercearia', 'farmácia', 'compras'],
    ),
    PremiumSearchItem(
      title: 'Mota de Água',
      subtitle: 'Aluguer premium na marina',
      keywords: ['jetski', 'mota', 'água', 'marina'],
    ),
    PremiumSearchItem(
      title: 'Guia de Ilhas',
      subtitle: 'Experiências e roteiros exclusivos',
      keywords: ['ilhas', 'guia', 'explorar', 'roteiro'],
    ),
  ];

  static List<PremiumSearchItem> filter(String query) {
    if (query.trim().isEmpty) return const [];
    return all.where((item) => item.matches(query)).toList();
  }
}
