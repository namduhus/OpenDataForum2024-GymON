import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class WeatherService {
  Future<Map<String, String>> fetchWeatherData() async {
    final now = DateTime.now();
    final String baseDate = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final String baseTime = now.hour.toString().padLeft(2, '0') + '00'; // 정시 기준

    final String apiUrl = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
        '?serviceKey=' // 발급받은 서비스 키
        '&pageNo=1'
        '&numOfRows=1000'
        '&dataType=XML'
        '&base_date=$baseDate'
        '&base_time=$baseTime'
        '&nx=55'
        '&ny=127';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final xml2json = Xml2Json();
        xml2json.parse(response.body);
        final jsonStr = xml2json.toParker();
        final data = json.decode(jsonStr);

        final items = data['response']['body']['items']['item'];
        String temperature = '';
        String rain = '';
        String skyCondition = '';
        String humidity = '';
        String windSpeed = '';
        String precipitationChance = '';
        String time = '';

        for (var item in items) {
          switch (item['category']) {
            case 'T1H':
              temperature = item['obsrValue'] + '°C';
              break;
            case 'RN1':
              rain = item['obsrValue'] == '0' ? '없음' : item['obsrValue'] + ' mm';
              break;
            case 'PTY':
              skyCondition = _getWeatherCondition(item['obsrValue']);
              break;
            case 'REH':
              humidity = item['obsrValue'] + '%';
              break;
            case 'WSD':
              windSpeed = item['obsrValue'] + ' m/s';
              break;
            case 'POP':
              precipitationChance = item['obsrValue'] + '%';
              break;
            case 'TM':
              time = item['obsrValue'];
              break;
          }
        }

        return {
          'temperature': temperature,
          'rain': rain,
          'weather': skyCondition,
          'humidity': humidity,
          'windSpeed': windSpeed,
          'precipitationChance': precipitationChance,
          'time': time,
          'sunscreenReminder': skyCondition == '맑음' ? '야외 스포츠 이용 시 선크림을 이용해주세요!' : ''
        };
      } else {
        return {'error': '날씨 정보를 불러오지 못했습니다.'};
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return {'error': '날씨 정보를 불러오는 중 오류가 발생했습니다.'};
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
