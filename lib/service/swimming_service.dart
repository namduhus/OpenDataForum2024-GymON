// service/swimming_service.dart
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class SwimmingService {
  final String apiKey = ''; // API 키를 입력하세요.

  Future<List<Map<String, String>>> fetchSwimmingClasses() async {
    final apiUrl = 'http://openAPI.seoul.go.kr:8088/$apiKey/xml/ListProgramByPublicSportsFacilitiesService/100/1000/수영';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        final items = data['ListProgramByPublicSportsFacilitiesService']['row'] ?? [];

        return items.map<Map<String, String>>((item) {
          return {
            'center': item['CENTER_NAME']?.toString() ?? '',
            'program': item['PROGRAM_NAME']?.toString() ?? '',
            'place': item['PLACE']?.toString() ?? '',
            'fee': item['FEE']?.toString() ?? '무료',
            'target': item['TARGET']?.toString() ?? '',
            'time': item['CLASS_TIME']?.toString() ?? '',
            'start': item['CLASS_S']?.toString() ?? '',
            'end': item['CLASS_E']?.toString() ?? '',
          };
        }).toList();
      } else {
        print("Failed to load swimming classes");
        return [];
      }
    } catch (e) {
      print('Error fetching swimming classes: $e');
      return [];
    }
  }
}
