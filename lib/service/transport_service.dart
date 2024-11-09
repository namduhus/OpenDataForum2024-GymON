import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransportService {
  final String apiKey = "API Key";

  // 대중교통 정보 가져오기
  Future<List<Map<String, dynamic>>> fetchTransportInfo(String facilityName) async {
    final url = Uri.parse('');
    final response = await http.get(url.replace(queryParameters: {
      'serviceKey': apiKey,
      'stSrch': facilityName,
    }));

    if (response.statusCode == 200) {
      final xml = Xml2Json();
      xml.parse(response.body);
      final jsonString = xml.toParker();
      final decodedResponse = json.decode(jsonString);

      if (decodedResponse['ServiceResult']['msgBody'] != null &&
          decodedResponse['ServiceResult']['msgBody']['areaList'] != null) {
        final areaList = decodedResponse['ServiceResult']['msgBody']['areaList'] is List
            ? decodedResponse['ServiceResult']['msgBody']['areaList']
            : [decodedResponse['ServiceResult']['msgBody']['areaList']];
        return areaList.map((area) {
          return {
            'name': area['poiNm'],
            'gpsX': area['gpsX'],
            'gpsY': area['gpsY'],
          };
        }).toList();
      } else {
        print("No transport data found in response");
        return [];
      }
    } else {
      print("Failed to fetch transport data: ${response.statusCode}");
      throw Exception("Failed to fetch transport data");
    }
  }

  // 기차 정보 가져오기
  Future<Map<String, dynamic>> fetchTrainInfo() async {
    final now = DateTime.now();
    final depPlandTime = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('');
    final response = await http.get(url.replace(queryParameters: {
      'serviceKey': apiKey,
      'depPlaceId': 'NAT014445',
      'arrPlaceId': 'NAT010000',
      'depPlandTime': depPlandTime,
      'pageNo': '5',
      'numOfRows': '1',
      '_type': 'xml',
      'trainGradeCode': '00'  // 기차 유형 코드 추가
    }));

    if (response.statusCode == 200) {
      final xml = Xml2Json();
      xml.parse(response.body);
      xml.parse(utf8.decode(response.bodyBytes));
      final jsonString = xml.toParker();
      final decodedResponse = json.decode(jsonString);

      print("XML Response:\n${response.body}");
      print("JSON Converted Response:\n$jsonString");

      final body = decodedResponse['response']?['body'];
      if (body != null && body['items'] != null && body['items']['item'] != null) {
        final item = body['items']['item'];

        // 출발 및 도착 시간을 원하는 형식으로 변환
        String formatTime(String timeString) {
          final year = timeString.substring(0, 4);
          final month = timeString.substring(4, 6);
          final day = timeString.substring(6, 8);
          final hour = timeString.substring(8, 10);
          final minute = timeString.substring(10, 12);
          return "$year년 $month월 $day일 $hour시 $minute분";
        }

        return {
          'depPlaceNm': item['depplacename'],
          'arrPlaceNm': item['arrplacename'],
          'depPlandTime': formatTime(item['depplandtime']),
          'arrPlandTime': formatTime(item['arrplandtime']),
          'trainGradeNm': item['traingradename'],
          'trainNo': item['trainno'],
          'charge': item['adultcharge']
        };
      } else {
        print("No train data found in response");
        return {};
      }
    } else {
      print("Failed to fetch train data: ${response.statusCode}");
      throw Exception("Failed to fetch train data");
    }
  }
}
