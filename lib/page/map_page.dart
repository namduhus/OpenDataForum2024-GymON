import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import '../service/bus_service.dart'; // BusService를 임포트

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final BusService _busService = BusService(); // BusService 인스턴스 추가

  // 서울역 좌표 (출발지)
  final LatLng _seoulStation = LatLng(37.5563, 126.9723);

  @override
  void initState() {
    super.initState();
    _loadMarkersFromJson();
    _addSeoulStationMarker();
  }

  // 서울역에 파란색 마커 추가
  void _addSeoulStationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("seoul_station"),
          position: _seoulStation,
          infoWindow: InfoWindow(title: "서울역 (출발지)"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  // JSON 파일에서 시설 마커 정보 불러오기
  Future<void> _loadMarkersFromJson() async {
    final jsonString = await rootBundle.loadString('assets/markers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      _markers.addAll(jsonData.map((data) {
        return Marker(
          markerId: MarkerId(data['id']),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: data['snippet'],
            onTap: () {
              _showTransportConfirmationDialog(data['title'], LatLng(data['latitude'], data['longitude']));
            },
          ),
          icon: BitmapDescriptor.defaultMarker,
        );
      }));
    });
  }

  // 대중교통 추천 여부를 묻는 확인창
  void _showTransportConfirmationDialog(String facilityName, LatLng destination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("대중교통 추천"),
        content: Text("해당 위치로 대중교통 추천 경로를 확인하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // "아니요" 선택 시 닫기
            child: Text("아니요"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 확인창 닫기
              _showTransportRecommendation(facilityName); // BusService 호출로 변경
            },
            child: Text("예"),
          ),
        ],
      ),
    );
  }

  // 대중교통 추천 팝업
  Future<void> _showTransportRecommendation(String facilityName) async {
    try {
      // BusService를 사용해 대중교통 정보 가져오기
      final transportData = await _busService.fetchTransportInfo(facilityName);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("서울역에서 $facilityName까지의 대중교통 경로"),
          content: transportData.isNotEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: transportData.map((data) {
              return ListTile(
                title: Text(data['name']),
                subtitle: Text("위치: (${data['gpsX']}, ${data['gpsY']})"),
              );
            }).toList(),
          )
              : Text("추천 경로가 없습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("닫기"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error fetching transport data: $e");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("오류"),
          content: Text("대중교통 데이터를 불러오는 중 오류가 발생했습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("닫기"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map with JSON Markers")),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 600,
              height: 400,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.5665, 126.9780),
                  zoom: 10,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            SizedBox(height: 30),
            Text("지도 아래에 다른 내용 추가 가능"),
          ],
        ),
      ),
    );
  }
}
