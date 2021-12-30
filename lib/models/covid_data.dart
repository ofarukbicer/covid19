class CovidData {
  final int confirmedCount;
  final int deathCount;
  final int recovryCount;
  final String flagUrl;
  final String name;
  final double lat;
  final double long;

  CovidData({
    required this.confirmedCount,
    required this.deathCount,
    required this.recovryCount,
    required this.flagUrl,
    required this.name,
    required this.lat,
    required this.long,
  });
}
