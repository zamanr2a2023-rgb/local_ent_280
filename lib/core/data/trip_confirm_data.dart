import 'package:flutter/material.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';

/// Dados do ecrã de confirmação de viagem — `roles/details.md`.
class TransportOption {
  const TransportOption({
    required this.id,
    required this.label,
    required this.price,
    required this.icon,
  });

  final String id;
  final String label;
  final double price;
  final IconData icon;
}

abstract final class TripConfirmData {
  static const mapImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBOuT1H0P-X7KV8Feq2lB3UHP-6ZKN5VAoV0EpTLoiAyyMTdETuthkyJ9hGSFkT4PJLT8Ck6ITyfcpDQ6YiRUjlOsiVVhPZuC2tsGn4GIYtejLfv0U3uReHqwDUFR5bZ4lgw0N2r8O654VnKRHLbYWgL-GIFTguyEwk2jNFlaNbcHEtNwGTkV-M4if3uvQ4TiNKf0RkB7PZYbZrE_Uu29tF4e2if37LTZqBnh77br607m2YEH6cVmn3Jr3nhab6o7H70Eugw2E';

  static const profileAvatarImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDbjzR9aNIio-uIssWv_E9VN8EQYs7OOI9GD9Piov3kT2R_F4M_VKTyapah4Y4pRmatbLJ4e8Z3BQa7LmUf07hYwIr2RCqWEOWRjzz3YI75UWqVZECCuROmDujHGBETkhwG_m3f3vHdWSKhFs69Py3XPAf22Ji5jBYIojZwL8PHa-K7yEGm2coHLc5a91yiTl47VvZnCQthP2d9ZUAQA9JkoMlP5P3M9Psrsj4mGc5Ptsff_ao13HUpNQ9URjiUm_bZrkvyIj5FZTk';

  static const pickupLabel = 'Avenida da Liberdade, 110';
  static const destinationLabel = 'Aeroporto de Lisboa (LIS)';
  static const distance = '8.4 km';
  static const duration = '14 min';
  static const cardMask = '**** 4421';

  static const transportOptions = [
    TransportOption(
      id: 'premium',
      label: 'Premium',
      price: 12.50,
      icon: Icons.directions_car,
    ),
    TransportOption(
      id: 'eco',
      label: 'Eco-Eletric',
      price: 10.80,
      icon: Icons.electric_car,
    ),
    TransportOption(
      id: 'shared',
      label: 'Partilhado',
      price: 6.40,
      icon: Icons.hail,
    ),
  ];
}
