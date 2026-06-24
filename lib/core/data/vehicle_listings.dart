/// Dummy fleet data for search results — `roles/details.md`.
class VehicleListing {
  const VehicleListing({
    required this.name,
    required this.pricePerDay,
    required this.imageUrl,
    required this.seats,
    required this.bags,
    required this.hasAc,
    required this.transmissionLabel,
    this.isPremium = false,
    this.isElectric = false,
  });

  final String name;
  final int pricePerDay;
  final String imageUrl;
  final int seats;
  final int bags;
  final bool hasAc;
  final String transmissionLabel;
  final bool isPremium;
  final bool isElectric;
}

abstract final class VehicleListings {
  static const premium = [
    VehicleListing(
      name: 'Mercedes-Benz E-Class',
      pricePerDay: 120,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDR_V2jczObZ9G6glYW5hOCuz9QjaUqbLT6RD7TRmk38Dnmc0WU38Qyz4bVRN47QdP0heuR4KMDrW02gyunHSTiF7UN-h0kFjHY1GuxP0NkQGb-ehzu-4sqso-HY7dHfidKRgqN3HNanGrXzcudYVt8wB91Qo2A_v-Y7aUbsCYmjz1L_S7GzvtzczlSOyVzvXTUS_18N02fL3yJm8KwEXdkvsi1FLz298tllNSe1C8l9uHDkOeAgkTAWfQr4HHp0sPp2X6Ho3Ziv9U',
      seats: 5,
      bags: 2,
      hasAc: true,
      transmissionLabel: 'Auto',
      isPremium: true,
    ),
    VehicleListing(
      name: 'BMW iX Electric',
      pricePerDay: 145,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKwU9pigxOdziIVm1Q_upXRmQxuHK28MeBwdMN-omkeEZLq_7Y89tfoCOQF0hsePeyygtADKBeaifu_50TVnu2EAbIPDH9D2G9PXS7RM8RPkRATj_lL28A5NN2djtoPJqlOqjvySWk704I3V8je8ASpyr-6P6OSLwlJFf324S4WfX6mBj0mcB-7A2rV6nB6s_4OFb6OeIOwOmh3AajqiZAQ-J-TX1y2qHvDmODolXywO1dqIALiWpeTIvcqYdYNJhnBZ5MQCWhh2I',
      seats: 5,
      bags: 3,
      hasAc: true,
      transmissionLabel: 'Auto',
      isPremium: true,
      isElectric: true,
    ),
  ];

  static const standard = [
    VehicleListing(
      name: 'Audi A3 Sedan',
      pricePerDay: 75,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC0wf68MA7UvgovN9KkTnPjgT1AytwgXuxaFqhJUNID--rZF5dFxsCMj4Py6LFiSQhEzyQTRZkZC2umGOAu_BX1pPOQr0FaPnW92pqLMVjV0YAwDefj7vMeWES27sFrp8a6W0d0f-N2ghO3V3e3HCjPMZ1GHlqOL4F9BPfrlY43vQy9rGE1olFFynS-kE0fweYWBgaU68GGLw6C9xxN9R0F6spu43nmlLG0KpiDXDGcQ-PYWkSz5DdFYnFLspeXtGsCTkjdvNtI1eM',
      seats: 5,
      bags: 1,
      hasAc: true,
      transmissionLabel: 'Manual',
    ),
    VehicleListing(
      name: 'Volkswagen Tiguan',
      pricePerDay: 90,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDPo1hcsWQGFyTb5_0QkeLSdHDosK2J9bVypaaO4VuK9wQBepPzdTzI5MGdAtl_6L3Ia6yKCTNDm849YIDWnXwjldPerl2e5gCHbha7AY53aaM8fhZvkuplWze63AfRSGU2qmJZdO656VfNbLgQ1AgDeNX1vgGn-KROn2ua-31o0efHmzKmFscQuv3CJizX79YDv1XZai2c4Fe1rWLcXWsuwTHBB1PP5-xK3iegADkcs6a5_WlyXpOvF-hpDvfG4WAkehpRI_OTwOo',
      seats: 5,
      bags: 3,
      hasAc: true,
      transmissionLabel: 'Auto',
    ),
    VehicleListing(
      name: 'Volvo XC60',
      pricePerDay: 110,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAXwWKm997_BLGrkCiT-NFLyO96L_q-VoWgvq3FRZyjv0mBUkTl7LzOpajud1wwswS9LfKlsUVUqabW8BD4kY79AleI65_OroKLH7JSv7kjyRF9qrLvXPJz6d-05tuKeLRtqmiva4qA7q1qxmbuamimQ1r9cfs6zLPwhFva0ZUjqnAu53pR5z7kgkgmo7jaQCu5edKXRl50DLGFxOopy5RSzoQY10ci8k9003_u9-5YNdqtj0xq1QTd7mlnPWBKQ3xC5UjF--MK-Ns',
      seats: 5,
      bags: 3,
      hasAc: true,
      transmissionLabel: 'Auto',
    ),
  ];

  static const String resultsProfileAvatarImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDRBmu8y79z_EAfpCTTyXgfURJalnEHA0WQy45oWhqVTcr9tQHnMUQqPZh5Qudid2cOglucL97fd_1pH9C5WfuqBvLXcYoRSdaHMDu7pcYZICE2UHX-l5hC1772YHCgl8X9KuSWPJT86IHga2JrPPRKmA9hZQdCLfNMXUytrjMiApgXuRHmqAjfR6AvMWsGHwQhB8HUjy9EnZXsSByp7wIzFutZKsxvXeGt5yrYUO2y7Yq71HATB-KDU_tRrmJRXWND2cnKOx-T1Sc';
}
