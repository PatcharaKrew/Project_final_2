import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/resultscreen.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final QuizSet quizSet;
  final int userId;
  final String userName;
  QuestionScreen(
      {required this.quizSet, required this.userId, required this.userName});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = List.filled(8, -1);
  List<int> _selectedAnswersHIV = List.filled(1, -1);
  List<int> _selectedAnswersSmoking = List.filled(8, -1);

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex == 1 &&
          widget.quizSet.name == "ตรวจสุขภาพ" &&
          _selectedAnswers[_currentQuestionIndex] != 0) {
        _currentQuestionIndex +=
            2; // ข้ามคำถามข้อที่ 2 ถ้าไม่ได้ตอบตัวเลือกที่ 1
      } else {
        _currentQuestionIndex++;
      }
    });
  }

  void _prevQuestion() {
    setState(() {
      if (_currentQuestionIndex == 3 &&
          widget.quizSet.name == "ตรวจสุขภาพ" &&
          _selectedAnswers[1] != 0) {
        _currentQuestionIndex -=
            2; // กลับไปคำถามข้อที่ 2 ถ้าเคยข้ามคำถามข้อที่ 2
      } else {
        _currentQuestionIndex--;
      }
    });
  }

  void _submitQuiz() {
    List<int> selectedAnswers;
    if (widget.quizSet.name == "ตรวจสุขภาพ") {
      selectedAnswers = _selectedAnswers;
    } else if (widget.quizSet.name == "เลิกบุหรี่") {
      selectedAnswers = _selectedAnswersSmoking;
    } else if (widget.quizSet.name == "HIV") {
      selectedAnswers = _selectedAnswersHIV;
    } else {
      selectedAnswers = [];
    }

    // Mark any unanswered question with an answer index that corresponds to a score of 0
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (selectedAnswers[i] == -1) {
        selectedAnswers[i] = widget.quizSet.questions[i].answers
            .indexWhere((answer) => answer.score == 0);
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          quizSet: widget.quizSet,
          selectedAnswers: selectedAnswers,
          userId: widget.userId,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quizSet.questions[_currentQuestionIndex];
    final selectedAnswers;
    if (widget.quizSet.name == "ตรวจสุขภาพ") {
      selectedAnswers = _selectedAnswers;
    } else if (widget.quizSet.name == "เลิกบุหรี่") {
      selectedAnswers = _selectedAnswersSmoking;
    } else if (widget.quizSet.name == "HIV") {
      selectedAnswers = _selectedAnswersHIV;
    } else {
      selectedAnswers = [];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundGradientEnd,
        iconTheme: IconThemeData(color: bottomBarIconColor),
        title: Text(
          widget.quizSet.name,
          style: TextStyle(color: bottomBarIconColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                currentQuestion.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: textColor1,
                    fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              ...currentQuestion.answers.map((answer) {
                int index = currentQuestion.answers.indexOf(answer);
                bool isSelected = selectedAnswers[_currentQuestionIndex] == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswers[_currentQuestionIndex] = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                backgroundGradientStart2,
                                backgroundGradientEnd
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      // color: isSelected ? buttonSelectedColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: backgroundGradientEnd, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isSelected ? Colors.white : backgroundGradientEnd,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _prevQuestion,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 20), 
                          SizedBox(
                              width: 8), 
                          Text(
                            'ย้อนกลับ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            backgroundGradientEnd, 
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15.0), // Border radius
                        ),
                        minimumSize: Size(140, 60), // Ensure equal size
                      ),
                    ),
                  Spacer(),
                  if (_currentQuestionIndex < widget.quizSet.questions.length - 1)
                    ElevatedButton(
                      onPressed: selectedAnswers[_currentQuestionIndex] == -1
                          ? null
                          : _nextQuestion,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ถัดไป',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                              width: 8), 
                          Icon(Icons.arrow_forward_ios, size: 20), 
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            buttonSelectedColor, 
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15.0), 
                        ),
                        minimumSize: Size(140, 60), // Ensure equal size
                      ),
                    ),
                  if (_currentQuestionIndex ==
                      widget.quizSet.questions.length - 1)
                    ElevatedButton(
                      onPressed: selectedAnswers[_currentQuestionIndex] == -1
                          ? null
                          : _submitQuiz,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ประเมิน',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                              width: 8), // Add some space between text and icon
                          Icon(Icons.check, size: 20), // Add icon
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor:
                            sucmintColor, // Button background color
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15.0), // Border radius
                        ),
                        minimumSize: Size(140, 60), // Ensure equal size
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
}
