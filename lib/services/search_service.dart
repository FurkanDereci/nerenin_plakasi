import '../models/city_plate.dart';
import '../data/plate_data.dart';

class SearchService {
  // Şehir ismine göre arama yapar
  List<CityPlate> searchByCity(String query) {
    if (query.isEmpty) return [];

    final normalized = _normalizeText(query);
    return PlateData.turkishPlates.where((plate) {
      final normalizedCity = _normalizeText(plate.city);
      return normalizedCity.contains(normalized);
    }).toList();
  }

  // Plaka koduna göre arama yapar
  List<CityPlate> searchByPlate(String query) {
    if (query.isEmpty) return [];
    return PlateData.turkishPlates
        .where((plate) => plate.plateCode.startsWith(query))
        .toList();
  }

  // Türkçe karakterleri normalize eder
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }
}
