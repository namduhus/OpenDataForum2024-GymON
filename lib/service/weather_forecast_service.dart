import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class WeatherForecastService {
  final String apiUrl = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
      '?serviceKey=' // 발급받은 서비스 키
      '&pageNo=1'
      '&numOfRows=200'
      '&dataType=XML'
      '&base_date=20241105' // 현재 날짜로 업데이트 필요
      '&base_time=0500'
      '&nx=55'
      '&ny=127';

  Future<List<Map<String, String>>> fetchWeatherForecast() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        final items = data['response']['body']['items']['item'];
        List<Map<String, String>> forecastData = [];

        for (var item in items) {
          final category = item['category'];
          final fcstDate = item['fcstDate'];
          final fcstTime = item['fcstTime'];
          final fcstValue = item['fcstValue'];

          if (category == 'T3H' || category == 'PTY' || category == 'REH' || category == 'WSD') {
            forecastData.add({
              'date': fcstDate,
              'time': fcstTime,
              'temperature': category == 'T3H' ? '$fcstValue°C' : '',
              'weather': category == 'PTY' ? _getWeatherCondition(fcstValue) : '',
              'humidity': category == 'REH' ? '$fcstValue%' : '',
              'windSpeed': category == 'WSD' ? '$fcstValue m/s' : '',
            });
          }
        }

        return forecastData;
      } else {
        print("Failed to load forecast data");
        return [];
      }
    } catch (e) {
      print('Error fetching forecast data: $e');
      return [];
    }
  }

  String _getWeatherCondition(String code) {
    switch (code) {
      case '0':
        return '맑음';
      case '1':
        return '비';
      case '2':
        return '비/눈';
      case '3':
        return '눈';
      default:
        return '정보 없음';
    }
  }
}
