import 'package:flutter/material.dart';
import 'MainPage.dart'; // MainPage.dart 파일을 불러옴

class LogoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD9E4EC), // 밝은 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2), // 상단 여백
            Image.asset(
              'assets/1.png',
              width: 400,
              height: 400, // 이미지 크기 증가
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3066BE), // 버튼 색상
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // 체육통합플랫폼으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()), // MainPage로 이동
                );
              },
              child: Text(
                "시작하기",
                style: TextStyle(
                  color: Color(0xFFECF0F1), // 버튼 텍스트 색상
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFF2F243A), // 두 번째 버튼 색상
            //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   onPressed: () {
            //     // 성동구 추천강좌플랫폼으로 이동
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => LecturePage()), // MainPage로 이동
            //     );
            //   },
            //   child: Text(
            //     "  성동구 체육시설 추천강좌 페이지  ",
            //     style: TextStyle(
            //       color: Color(0xFFECF0F1), // 버튼 텍스트 색상
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Spacer(flex: 3), // 하단 여백
          ],
        ),
      ),
    );
  }
}
