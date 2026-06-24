import 'package:flutter/material.dart';

/// Destinos e favoritos — `roles/details.md`.
class TripPlace {
  const TripPlace({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.filledIcon = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool filledIcon;
}

abstract final class TripDestinationData {
  static const profileAvatarImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9UjWu8QMQkYqbc8IFLJxgGy1UUVN_n6GEaFdhf93wj1KvtLWJzKpTsGWpoibysL7gCEcWlli4lBw18lWIaGy7eE0W0hRtRNiBf1YwNO0KQBD3iirBTZUwuNhyYdSdYa3TBqP74EIRkAj1S02nGW4WqX2-EPtkuhO2bwJ9M23sjN7APmYiWP5-HLMoAFB4WcUUQ-IBngU0M4kdYzCiirAdnRQfFzGMIU5MaYaME-UVHmTCRCqIWsU431vMlbDGSiSyntFxnYZ6eFw';

  static const suggestionBannerImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDS2uGcmdH_Z_s1Im6lynV_prxncOKktW0Yv-qxZgGbj4bJU0meafMBAeEO4sndazLzETy6ZuNMIC0NAjs9G12J2bEnI2gZ9L0A8iLpi4asE-mOOvXO9LchcOsi_LLSqXnSHzf0LLwo2Uo3PNFkw2RbJpoq-rRYbfiZPFQZSVQd_YZAsw5pX7Tvz0eCTASKmiO5_FejBe3AEEX_o65FvOA39c-QjZ9qNJNIrcuvEp-yhDcYRh4UJLi1GODPHDQKTfBfhvse6ERfrtQ';

  static const exploreMapImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDref4wfG_Ls4NHQUNySp7r7oPsGla4TTIBv_gTvws7ItTgYtVIhaXKuA-lJKX4WJroCyzrAkdhJN0BpG89jhG3IwfiFWrh7U0RzzQcvk67VBN2tTcavl9vnuJwS9zJjAoB1_qGIzllV97rp3aPdiajSIi6ej8gd8OBC870KNQcvMm2MywYYsM0UJjnSJmkFZCGJqEInNWfsw62Asr5AfD78uIY-vJ2wpKVEvZM82mn5JwaMlrPrjRGXRP5RBi7LKPRL-hXbKiaVVA';

  static const recentPlaces = [
    TripPlace(
      title: 'Lisbon Airport (LIS)',
      subtitle: 'Alameda das Comunidades Portuguesas',
      icon: Icons.history,
    ),
    TripPlace(
      title: 'Oriente Station',
      subtitle: 'Orient Station Building, Floor 1',
      icon: Icons.history,
    ),
  ];

  static const favorites = [
    TripPlace(
      title: 'Home',
      subtitle: 'Rua Rosa Araújo, 12',
      icon: Icons.home,
      filledIcon: true,
    ),
    TripPlace(
      title: 'Work',
      subtitle: 'Avenida Fontes Pereira de Melo, 40',
      icon: Icons.work,
      filledIcon: true,
    ),
  ];
}
