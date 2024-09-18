import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/date_result.dart';
import 'package:final_login/screen/homeDevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final QuizSet quizSet;
  final List<int> selectedAnswers;
  final int userId;
  final String userName;
  ResultScreen({
    required this.quizSet,
    required this.selectedAnswers,
    required this.userId,
    required this.userName,
    
  });

  Future<Map<String, dynamic>> _fetchHealthData() async {
    final response = await http.get(
      Uri.parse('http://192.168.110.211:3000/profile/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load health data');
    }
  }

  void _submitResults(int userId, String programName, String resultProgram,
      DateTime appointmentDate) async {
    final response = await http.post(
      Uri.parse('http://192.168.110.211:3000/evaluation-results'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'user_id': userId,
        'program_name': programName,
        'result_program': resultProgram,
        'appointment_date': appointmentDate
            .toIso8601String()
            .substring(0, 10), // แปลงเป็น string
      }),
    );

    if (response.statusCode == 201) {
      // Handle success response
    } else {
      // Handle error response
    }
  }

  Future<int> _calculateTotalScore() async {
    int totalScore = 0;

    // คำนวณคะแนนจากการตอบคำถาม
    for (int i = 0; i < selectedAnswers.length; i++) {
      int selectedIndex = selectedAnswers[i];
      if (selectedIndex >= 0 &&
          selectedIndex < quizSet.questions[i].answers.length) {
        totalScore += quizSet.questions[i].answers[selectedIndex].score;
      }
    }

    // ถ้าเป็นแบบทดสอบ "ตรวจสุขภาพ" ให้ดึงข้อมูลและคำนวณคะแนนเพิ่ม
    if (quizSet.name == "ตรวจสุขภาพ") {
      try {
        final healthData = await _fetchHealthData();
        double? bmi = double.tryParse(healthData['bmi'].toString());
        double? waistToHeightRatio =
            double.tryParse(healthData['waist_to_height_ratio'].toString());

        // คำนวณคะแนนจาก BMI
        if (bmi != null) {
          if (bmi < 23) {
            totalScore += 0;
          } else if (bmi < 27.5) {
            totalScore += 1;
          } else {
            totalScore += 3;
          }
        }

        // คำนวณคะแนนจาก Waist-to-Height Ratio
        if (waistToHeightRatio != null) {
          if (waistToHeightRatio < 0.4) {
            totalScore += 0;
          } else if (waistToHeightRatio < 0.6) {
            totalScore += 3;
          } else {
            totalScore += 5;
          }
        }
      } catch (e) {
        // จัดการกับข้อผิดพลาดในการดึงข้อมูลสุขภาพ
      }
    }

    return totalScore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: bottomBarIconColor),
        title: Text(
          quizSet.name,
          style: TextStyle(color: bottomBarIconColor),
        ),
      ),
      body: FutureBuilder<int>(
        future: _calculateTotalScore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            int totalScore = snapshot.data ?? 0;
            String resultProgram;

            if (quizSet.name == "ตรวจสุขภาพ") {
              resultProgram = buildEvaluationResult(totalScore);
            } else if (quizSet.name == "เลิกบุหรี่") {
              resultProgram = smokerneenaaResult(totalScore);
            } else if (quizSet.name == "HIV") {
              resultProgram =
                  quizSet.questions[0].answers[selectedAnswers[0]].text;
            } else {
              resultProgram = "unknown";
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
                      if (quizSet.name == "ตรวจสุขภาพ") ...[
                        Text('แบบประเมินความเสี่ยงสุขภาพ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        Text('ผลการประเมิน : $totalScore คะแนน',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.0,
                              color: subtextColor,
                            )),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SpinKitRipple(
                              color: Color(0xFFDD3F43).withOpacity(0.7),
                              size: 270.0,
                            ),
                            ClipOval(
                              child: Image.asset(
                                'assets/images/Heal.png',
                                width: 250.0,
                                height: 250.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        buildEvaluationButton(totalScore),
                        SizedBox(height: 20),
                      ],
                      if (quizSet.name == "HIV") ...[
                        Text('โปรแกรมตรวจ HIV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipPath(
                              child: Image.asset(
                                'assets/images/hiv.png',
                                width: 250.0,
                                height: 250.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                            'คุณต้องการ : ${quizSet.questions[0].answers[selectedAnswers[0]].text}',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 22.0, color: subtextColor)),
                        SizedBox(height: 10),
                      ],
                      if (quizSet.name == "เลิกบุหรี่") ...[
                        Text('แบบประเมินวัดระดับการติดนิโคติน',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        Text('ผลการประเมินของได้ $totalScore คะแนน',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 22.0, color: subtextColor)),
                        SizedBox(height: 10),
                        Image.asset(
                          'assets/images/smoke.png',
                          fit: BoxFit.fill,
                        ),
                        smokerneenaa(totalScore),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeDevicePage(
                                      userName: userName,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.home_outlined),
                              label: Text('หน้าหลัก',
                                  style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: buttonTextColor,
                                backgroundColor: nextButtonColor,
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentScreen(
                                      quizSet: quizSet,
                                      userId: userId,
                                      resultProgram: resultProgram,
                                      userName: userName,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.calendar_month_outlined),
                              label:
                                  Text('ลงนัด', style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: buttonTextColor,
                                backgroundColor: nextButtonColor,
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildEvaluationButton(int score) {
    String text;
    String textdetails;
    Color color;
    Color textColor;

    if (score >= 15) {
      text = 'เสี่ยงสูง';
      color = Colors.red[100]!;
      textColor = Colors.red;
      textdetails = 'พบแพทย์เพื่อรับคำปรึกษาและตรวจสุขภาพเชิงลึกทันที';
    } else if (score >= 9 && score < 15) {
      text = 'เสี่ยงปานกลาง';
      color = Colors.yellow[100]!;
      textColor = Colors.yellow[800]!;
      textdetails =
          'ควรปรับเปลี่ยนพฤติกรรมสุขภาพ เพิ่มการออกกำลังกายหลีกเลี่ยงพฤติกรรมเสี่ยงและตรวจสุขภาพเพิ่มเติมกับแพทย์เพื่อป้องกันการพัฒนาไปสู่ความเสี่ยงสูง ';
    } else if (score < 9) {
      text = 'เสี่ยงต่ำ';
      color = Colors.green[100]!;
      textColor = Colors.green;
      textdetails =
          'รักษาพฤติกรรมสุขภาพดี ควรตรวจสุขภาพประจำปีเพื่อเฝ้าระวังการเปลี่ยนแปลงด้านสุขภาพ';
    } else {
      text = 'error';
      color = Colors.grey[100]!;
      textColor = Colors.black;
      textdetails = '-';
    }
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ข้อแนะนํา : ',
                style: TextStyle(color: textColor, fontSize: 22),
              ),
              TextSpan(
                text: textdetails,
                style: TextStyle(color: subtextColor, fontSize: 22),
              ),
            ],
          ),
        )
      ],
    );
  }

  String buildEvaluationResult(int score) {
    if (score >= 15) {
      return 'เสี่ยงสูง';
    } else if (score >= 9) {
      return 'เสี่ยงปานกลาง';
    } else if (score < 9) {
      return 'เสี่ยงต่ำ';
    } else {
      return 'error';
    }
  }

  String smokerneenaaResult(int score) {
    if (score >= 6) {
      return 'ติดบุหรี่มาก';
    } else if (score >= 4 && score < 6) {
      return 'ติดบุหรี่ปานกลาง';
    } else if (score >= 0 && score < 4) {
      return 'ติดบุหรี่น้อย';
    } else {
      return 'error';
    }
  }
}

Widget smokerneenaa(int score) {
  String text;
  Color color;
  Color textColor;

  if (score >= 6) {
    text = 'ติดบุหรี่มาก';
    color = Colors.red[100]!;
    textColor = Colors.red;
  } else if (score >= 4 && score < 6) {
    text = 'ติดบุหรี่ปานกลาง';
    color = Colors.yellow[100]!;
    textColor = Colors.yellow[800]!;
  } else if (score >= 0 && score < 4) {
    text = 'ติดบุหรี่น้อย';
    color = Colors.green[100]!;
    textColor = Colors.green;
  } else {
    text = 'error';
    color = Colors.grey[100]!;
    textColor = Colors.black;
  }
  return Container(
    margin: EdgeInsets.symmetric(
      vertical: 20.0,
    ),
    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
