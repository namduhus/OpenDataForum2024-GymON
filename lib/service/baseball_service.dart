// service/baseball_service.dart
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class BaseballService {
  final String apiUrl =
      'http://openAPI.seoul.go.kr:8088/API Key/xml/ListProgramByPublicSportsFacilitiesService/1/50/야구';

  Future<List<Map<String, String>>> fetchBaseballClasses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        if (data['ListProgramByPublicSportsFacilitiesService']['row'] != null) {
          final items = data['ListProgramByPublicSportsFacilitiesService']['row'];

          List<Map<String, String>> baseballClasses = [];
          for (var item in items) {
            if (item['TERM'] != null && item['TARGET'] != null && item['PLACE'] != null) {
              baseballClasses.add({
                'facility': item['CENTER_NAME'] ?? '정보 없음',
                'program': item['PROGRAM_NAME'] ?? '정보 없음',
                'place': item['PLACE'] ?? '정보 없음',
                'fee': item['FEE'] ?? '정보 없음',
                'target': item['TARGET'] ?? '정보 없음',
                'time': item['CLASS_TIME'] ?? '정보 없음',
                'start': item['CLASS_S'] ?? '정보 없음',
                'end': item['CLASS_E'] ?? '정보 없음',
              });
            }
          }
          return baseballClasses;
        } else {
          return [];
        }
      } else {
        print("Failed to load baseball classes");
        return [];
      }
    } catch (e) {
      print('Error fetching baseball classes: $e');
      return [];
    }
  }
}
