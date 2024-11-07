import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class BusService {
  final String apiKey = "API KEY"; // Replace with your actual API key

  // Method to fetch transport info based on facility name
  Future<List<Map<String, dynamic>>> fetchTransportInfo(String facilityName) async {
    final url = Uri.parse('http://ws.bus.go.kr/api/rest/pathinfo/getLocationInfo');
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
}
