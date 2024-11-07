import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class LectureService {
  final String apiUrl = 'https://sports.happysd.or.kr/rest/common/PublicData?serviceTypeCode=1';

  Future<List<Map<String, String>>> fetchLectureData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        final items = data['services']['service'];
        List<Map<String, String>> lectures = [];

        for (var item in items) {
          lectures.add({
            'serviceName': item['svcnm'] ?? '정보 없음',
            'startDate': item['rcptbgndt'] ?? '정보 없음',
            'endDate': item['rcptenddt'] ?? '정보 없음',
            'useStartDate': item['usebgndate'] ?? '정보 없음',
            'useEndDate': item['useenddate'] ?? '정보 없음',
            'pay': item['payat'] ?? '정보 없음',
            'placeName': item['placenm'] ?? '정보 없음',
            'targetInfo': item['usetgtcd'] ?? '정보 없음',
            'serviceURL': item['svcurl'] ?? '정보 없음',
            'imgURL': item['imgurl'] ?? '',
            'contact': item['telno'] ?? '정보 없음',
            'latitude': item['x'] ?? '',
            'longitude': item['y'] ?? '',
            'details': item['dtlcont'] ?? '정보 없음',
          });
        }
        return lectures;
      } else {
        print("Failed to load lecture data");
        return [];
      }
    } catch (e) {
      print('Error fetching lecture data: $e');
      return [];
    }
  }
}
