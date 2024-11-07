import 'package:flutter/material.dart';
import '../service/weather_service.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, String> currentWeather = {};

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final weatherService = WeatherService();
    final currentData = await weatherService.fetchWeatherData();

    setState(() {
      currentWeather = currentData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeatherCard(),
            SizedBox(height: 20),
            _buildNoticeBoard(),
            SizedBox(height: 10),
            _buildSportsBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("서울특별시 현재 날씨", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange, size: 40),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat, color: Colors.red, size: 20),
                        SizedBox(width: 5),
                        Text("기온: ${currentWeather['temperature'] ?? '정보 없음'}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.blue, size: 20),
                        SizedBox(width: 5),
                        Text("날씨: ${currentWeather['weather'] ?? '정보 없음'}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.teal, size: 20),
                        SizedBox(width: 5),
                        Text("습도: ${currentWeather['humidity'] ?? '정보 없음'}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.air, color: Colors.grey, size: 20),
                        SizedBox(width: 5),
                        Text("풍속: ${currentWeather['windSpeed'] ?? '정보 없음'}"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (currentWeather['sunscreenReminder'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  currentWeather['sunscreenReminder'] ?? "",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeBoard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: Colors.blue, size: 30),
                SizedBox(width: 8),
                Text("공지사항", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red, size: 20),
                SizedBox(width: 5),
                Text("야외 스포츠 이용 시 유의사항을 확인해주세요."),
              ],
            ),
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red, size: 20),
                SizedBox(width: 5),
                Text("날씨에 따라 이용에 제한이 있을 수 있습니다."),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_box, color: Colors.green, size: 20),
                SizedBox(width: 5),
                Text("현재 Beta 버전입니다. 정시 출시일 전까지 편하게 이용해주세요 감사합니다."),
              ],
            ),
            Row(
              children: [
                Icon(Icons.celebration_rounded, color: Colors.purple, size: 20),
                SizedBox(width: 5),
                Text("남두현, 박재현 학생 오픈데이터 포럼 대회준비"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsBanner() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildBanner(context, "야구", Icons.sports_baseball, Colors.red, '/Baseball'),
        _buildBanner(context, "축구/족구", Icons.sports_soccer, Colors.green, '/Soccer'),
        _buildBanner(context, "수영장", Icons.pool, Colors.blue, '/Swim'),
        _buildBanner(context, "배드민턴", Icons.sports_tennis, Colors.orange, '/Badminton'),
        _buildBanner(context, "농구", Icons.sports_basketball, Colors.brown, '/Basketball'),
        _buildBanner(context, "테니스", Icons.sports_tennis, Colors.purple, '/Tennis'),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route); // 각 배너 클릭 시 해당 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
