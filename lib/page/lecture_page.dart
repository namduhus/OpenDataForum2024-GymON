import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../service/lecture_service.dart';

class LecturePage extends StatefulWidget {
  @override
  _LecturePageState createState() => _LecturePageState();
}

class _LecturePageState extends State<LecturePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  List<Map<String, String>> lectures = [];

  @override
  void initState() {
    super.initState();
    _fetchLectureData();
  }

  Future<void> _fetchLectureData() async {
    final lectureService = LectureService();
    final lectureData = await lectureService.fetchLectureData();

    setState(() {
      lectures = lectureData;
      _markers.addAll(
        lectureData.map((data) {
          double latitude = double.tryParse(data['latitude'] ?? '') ?? 0;
          double longitude = double.tryParse(data['longitude'] ?? '') ?? 0;
          if (latitude != 0 && longitude != 0) {
            return Marker(
              markerId: MarkerId(data['serviceName'] ?? 'Unknown'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: data['serviceName'],
                snippet: data['placeName'],
              ),
            );
          } else {
            return null;
          }
        }).whereType<Marker>().toSet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.5665, 126.9780),
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: lectures.length,
                itemBuilder: (context, index) {
                  final lecture = lectures[index];
                  return ListTile(
                    title: Text(lecture['serviceName'] ?? '알 수 없는 강좌명'),
                    subtitle: Text("장소: ${lecture['placeName'] ?? '알 수 없는 장소'}"),
                    trailing: ElevatedButton(
                      onPressed: () => _showConsentDialog(lecture),
                      child: Text("강좌신청"),
                    ),
                    onTap: () {
                      _showLectureDetails(lecture);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLectureDetails(Map<String, String> lecture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lecture['serviceName'] ?? '알 수 없는 강좌명'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("장소명: ${lecture['placeName'] ?? '정보 없음'}"),
            Text("접수 시작일: ${lecture['startDate'] ?? '정보 없음'}"),
            Text("접수 종료일: ${lecture['endDate'] ?? '정보 없음'}"),
            Text("이용 시작일: ${lecture['useStartDate'] ?? '정보 없음'}"),
            Text("이용 종료일: ${lecture['useEndDate'] ?? '정보 없음'}"),
            Text("이용 대상: ${lecture['targetInfo'] ?? '정보 없음'}"),
            Text("연락처: ${lecture['contact'] ?? '정보 없음'}"),
          ],
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

  // 개인정보 동의 팝업
  void _showConsentDialog(Map<String, String> lecture) {
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("개인정보 동의"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("강좌 ${lecture['serviceName']} 신청을 위해 개인정보 동의가 필요합니다."),
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
              onPressed: isChecked ? () => _showFormDialog() : null,
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

  // 신청 폼 다이얼로그
  void _showFormDialog() {
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
                _showConfirmationDialog();
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
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("강좌신청 완료"),
        content: Text("강좌신청이 완료되었습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인"),
          ),
        ],
      ),
    );
  }
}
