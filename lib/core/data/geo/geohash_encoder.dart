class GeoHashEncoder {
  const GeoHashEncoder();

  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  String encode({
    required double latitude,
    required double longitude,
    required int precision,
  }) {
    var latMin = -90.0;
    var latMax = 90.0;
    var lonMin = -180.0;
    var lonMax = 180.0;
    var isEven = true;
    var bit = 0;
    var ch = 0;
    final buffer = StringBuffer();
    while (buffer.length < precision) {
      if (isEven) {
        final mid = (lonMin + lonMax) / 2;
        if (longitude >= mid) {
          ch |= 1 << (4 - bit);
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (latitude >= mid) {
          ch |= 1 << (4 - bit);
          latMin = mid;
        } else {
          latMax = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit += 1;
      } else {
        buffer.write(_base32[ch]);
        bit = 0;
        ch = 0;
      }
    }
    return buffer.toString();
  }
}
