import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import '../service/badminton_service.dart';
import 'package:geolocator/geolocator.dart';
import '../service/transport_service.dart';

class BadmintonPage extends StatefulWidget {
  @override
  _BadmintonPageState createState() => _BadmintonPageState();
}

class _BadmintonPageState extends State<BadmintonPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _facilities = [];
  final TransportService _transportService = TransportService();
  bool isChecked = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadMarkersAndData();
    _determinePosition();
  }
  // 위치 권한 요청 및 현재 위치 가져오기
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스를 활성화하세요.');
    }

    // 위치 권한 확인 및 요청
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    // 현재 위치 가져오기
    _currentPosition = await Geolocator.getCurrentPosition();
    print("Current Position: $_currentPosition");
    _updateMapLocation();
  }

  // 현재 위치를 지도에 표시하기
  Future<void> _updateMapLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15,
        ),
      ));

      setState(() {
        _markers.add(Marker(
          markerId: MarkerId("current_location"),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(title: "현재 위치"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
    }
  }

  // JSON 파일에서 마커 및 시설 정보 불러오기
  Future<void> _loadMarkersAndData() async {
    final jsonString = await rootBundle.loadString('assets/badminton.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      _facilities = jsonData.map<Map<String, dynamic>>((data) => data).toList();
      _markers.addAll(jsonData.map((data) {
        return Marker(
          markerId: MarkerId(data['id']),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: data['snippet'],
          ),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            _showTransportConfirmationDialog(data['title']);
          },
        );
      }));
    });
  }
  // 대중교통 추천 여부를 묻는 확인창
// 대중교통 및 기차 추천 여부를 묻는 확인창
  void _showTransportConfirmationDialog(String facilityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("교통 추천"),
        content: Text("해당 위치로 대중교통이나 기차 정보를 조회할까요?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // "아니요" 선택 시 닫기
            child: Text("아니요"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTransportOptions(facilityName); // 교통 옵션 선택 팝업 호출
            },
            child: Text("예"),
          ),
        ],
      ),
    );
  }

  // 교통 옵션 선택 팝업
  void _showTransportOptions(String facilityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("교통 옵션"),
        content: Text("대중교통 또는 기차 정보를 선택하세요."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTransportRecommendation(facilityName); // 대중교통 조회
            },
            child: Text("대중교통"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchAndShowTrainInfo(); // 기차 정보 조회
            },
            child: Text("기차 정보"),
          ),
        ],
      ),
    );
  }

  // 대중교통 추천 팝업
  Future<void> _showTransportRecommendation(String facilityName) async {
    try {
      final transportData = await _transportService.fetchTransportInfo(facilityName);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("대중교통 추천 경로"),
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
      _showErrorDialog("대중교통 데이터를 불러오는 중 오류가 발생했습니다.");
    }
  }

  // 기차 정보 조회
  Future<void> _fetchAndShowTrainInfo() async {
    try {
      final trainData = await _transportService.fetchTrainInfo();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("기차 정보"),
          content: trainData.isNotEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("출발역: ${trainData['depPlaceNm']}"),
              Text("도착역: ${trainData['arrPlaceNm']}"),
              Text("출발 시간: ${trainData['depPlandTime']}"),
              Text("도착 시간: ${trainData['arrPlandTime']}"),
              Text("기차 번호: ${trainData['trainNo']}"),
              Text("요금: ${trainData['charge']}원"),
              Text("기차 종류: ${trainData['trainGradeNm']}")
            ],
          )
              : Text("해당 경로에 대한 열차 정보를 찾을 수 없습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("닫기"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error fetching train data: $e");
      _showErrorDialog("기차 정보를 불러오는 중 오류가 발생했습니다.");
    }
  }

  // 오류 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("오류"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("닫기"),
          ),
        ],
      ),
    );
  }

  // 배드민턴 강좌 팝업 창 열기
  // 배드민턴 강좌 팝업 창 열기
  Future<void> _showBadmintonClasses() async {
    final badmintonService = BadmintonService();
    final classes = await badmintonService.fetchBadmintonClasses();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("배드민턴 강좌 목록"),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey), // 각 강좌마다 구분선 추가
            itemBuilder: (context, index) {
              final badmintonClass = classes[index];
              return ListTile(
                title: Text(badmintonClass['program']!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("시설명: ${badmintonClass['facility']}"),
                    Text("장소: ${badmintonClass['place']}"),
                    Text("수강료: ${badmintonClass['fee']}"),
                    Text("대상: ${badmintonClass['target']}"),
                    Text("시간: ${badmintonClass['time']}"),
                    Text("기간: ${badmintonClass['start']} ~ ${badmintonClass['end']}"),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _showClassConsentDialog(badmintonClass['program']!), // 개인정보 체크 폼으로 이동
                  child: Text("신청"),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("닫기"),
          ),
        ],
      ),
    );
  }

  // 강좌 신청용 개인정보 동의 및 입력 폼
  void _showClassConsentDialog(String programName) {
    setState(() => isChecked = false);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("개인정보 동의"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$programName 프로그램을 신청하려면 개인정보 동의가 필요합니다."),
              CheckboxListTile(
                title: Text("개인정보 수집에 동의합니다."),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isChecked ? () => _showClassFormDialog(programName) : null,
              child: Text("확인"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        ),
      ),
    );
  }

  // 수강생 정보 입력 폼 다이얼로그
  void _showClassFormDialog(String programName) {
    Navigator.of(context).pop(); // 개인정보 동의 창 닫기
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    String gender = '남';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("수강생 정보 입력"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "성명"),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: "나이"),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Text("성별: "),
                    Radio<String>(
                      value: '남',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    Text("남"),
                    Radio<String>(
                      value: '여',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    Text("여"),
                  ],
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: "거주지"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 폼 닫기
                _showConfirmationDialog("강좌 신청 완료");
              },
              child: Text("확인"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        ),
      ),
    );
  }

  // 장소 이용 신청용 개인정보 동의 및 입력 폼
  void _showFacilityConsentDialog(String facilityName) {
    setState(() => isChecked = false);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("개인정보 동의"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$facilityName 시설을 이용하려면 개인정보 동의가 필요합니다."),
              CheckboxListTile(
                title: Text("개인정보 수집에 동의합니다."),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isChecked ? () => _showFacilityFormDialog(facilityName) : null,
              child: Text("확인"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        ),
      ),
    );
  }

  // 이용자 정보 입력 폼 다이얼로그
  void _showFacilityFormDialog(String facilityName) {
    Navigator.of(context).pop(); // 개인정보 동의 창 닫기
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    String gender = '남';

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        title: Text("이용자 정보 입력"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "성명"),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: "나이"),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Text("성별: "),
                  Radio<String>(
                    value: '남',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                  Text("남"),
                  Radio<String>(
                    value: '여',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                  Text("여"),
                ],
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "거주지"),
              ),
            ],
          ),
        ),
        actions: [
        TextButton(
        onPressed: () {
      Navigator.of(context).pop(); // 폼 닫기
      _showConfirmationDialog("장소 신청 완료");
    },
    child: Text("확인"),
    ),
    TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: Text("취소"),
    ),
    ],
    ),
    ),
    );
  }

  // 신청 완료 확인 다이얼로그
  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: Text("$message가 완료되었습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
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
              Expanded(
                flex: 3,
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final facility = _facilities[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(facility['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("자치구: ${facility['district']}"),
                            Text("운영시간 (평일): ${facility['weekdayHours']}"),
                            Text("운영시간 (주말): ${facility['weekendHours']}"),
                            Text("시설대관 여부: ${facility['rentalAvailable']}"),
                            Text("시설사용료: ${facility['rentalFee']}"),
                          ],
                        ),
                        leading: Icon(Icons.sports_tennis, color: Colors.orange),
                        trailing: facility['rentalAvailable'] == '가능'
                            ? ElevatedButton(
                          onPressed: () => _showFacilityConsentDialog(facility['title']),
                          child: Text("장소이용신청"),
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 20,
            child: ElevatedButton(
              onPressed: _showBadmintonClasses,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '강좌신청',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
