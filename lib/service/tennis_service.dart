// service/tennis_service.dart
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class TennisService {
  final String apiUrl =
      'http://openAPI.seoul.go.kr:8088/API KEY/xml/ListProgramByPublicSportsFacilitiesService/10/50/테니스';

  Future<List<Map<String, String>>> fetchTennisClasses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        // 예외 처리 추가: 데이터 구조 확인
        if (data['ListProgramByPublicSportsFacilitiesService'] == null ||
            data['ListProgramByPublicSportsFacilitiesService']['row'] == null) {
          print("Error: Unexpected data structure or no data available.");
          return [];
        }

        final items = data['ListProgramByPublicSportsFacilitiesService']['row'];
        List<Map<String, String>> tennisClasses = [];

        // API 응답이 단일 항목일 경우 List로 감싸기
        final itemList = items is List ? items : [items];

        for (var item in itemList) {
          tennisClasses.add({
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

        print("Fetched tennis classes: $tennisClasses");  // 디버깅 출력
        return tennisClasses;
      } else {
        print("Failed to load tennis classes. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('Error fetching tennis classes: $e');
      return [];
    }
  }
}
