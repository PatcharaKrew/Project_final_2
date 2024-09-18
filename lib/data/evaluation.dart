import 'package:flutter/material.dart';

class Answer {
  final String text;
  final int score;

  Answer(this.text, this.score);
}

class Question {
  final String text;
  final List<Answer> answers;

  Question(this.text, this.answers);
}

class QuizSet {
  final String name;
  final List<Question> questions;
  final IconData icon;

  QuizSet(this.name, this.questions, this.icon);
}

List<QuizSet> getSampleQuizSets() {
  return [
    QuizSet(
      "ตรวจสุขภาพ",
      [
        Question("ข้อมูลครอบครัวมีประวัติโรคเบาหวานในญาติสายตรง พ่อ-แม่-พี่-น้อง ?", [
          Answer("มี", 2),
          Answer("ไม่มี", 0),
        ]),
        Question("ท่านมีโรคประจำตัวหรือไม่ ?", [
          Answer("มี", 3),
          Answer("ไม่มี", 1),
        ]),
        Question("ท่านรักษาอย่างไร ?", [
          Answer("รักษาต่อเนื่อง", 3),
          Answer("รักษาไม่สมำเสมอ/ขาดยา", 1),
        ]),
        Question("ท่านเป็นโรคเบาหวานหรือไม่ ?", [
          Answer("เป็น", 3),
          Answer("ไม่เป็น", 1),
        ]),
        Question("ท่านเป็นโรคความดันโลหิตสูงหรือไม่ ?", [
          Answer("เป็น", 3),
          Answer("ไม่เป็น ", 1),
        ]),
        Question("ท่านเป็นโรคอัมพาตหรือไม่ ?", [
          Answer("เป็น", 3),
          Answer("ไม่เป็น", 1),
        ]),
        Question("ท่านสูบบุหรี่หรือไม่ ?", [
          Answer("สูบ", 3),
          Answer("ไม่สูบ", 1),
          Answer("เคยสูบแต่เลิกแล้วมากกว่า 1 ปี", 0),
        ]),
        Question("ท่านดื่มเครื่องดื่มAlcoholeหรือไม่ ?", [
          Answer("ดื่ม", 3),
          Answer("ไม่ดื่ม", 1),
        ]),
      ],
      Icons.monitor_heart, 
    ),
    QuizSet(
      "HIV",
      [
        Question("คุณต้องการ?", [
          Answer("ตรวจเชื้อHIV/Sysphilis", 3),
          Answer("รับยาป้องกันโรคเอดส์(PrEP)", 1),
          Answer("คุณต้องการรับถุงยาง", 0),
          Answer("อื่นๆ", 0)
        ]),
      ],
      Icons.health_and_safety, 
    ),
    QuizSet(
      "เลิกบุหรี่",
      [
        Question("ท่านสูบบุหรี่หรือไม่ ?", [
          Answer("ไม่สูบ", 0),
          Answer("สูบแต่เลิกแล้ว", 1),
          Answer("สูบ", 2),
        ]),
        Question("ท่านสูบบุหรี่กี่ครั้งต่อวัน ?", [
          Answer("น้อยกว่าหรือเท่ากับ 10 ครั้ง", 0),
          Answer("11-20 ครั้ง", 1),
          Answer("21-30 ครั้ง", 2),
          Answer("31 ครั้งขึ้นไป", 3)
        ]),
        Question("ระยะเวลาที่ท่านสูบบุหรี่ครั้งแรกหลังตื่นนอน ?", [
          Answer("ภายใน 5 นาทีหลังตื่นนอน", 3),
          Answer("6-30 นาที หลังตื่นนอน", 1),
          Answer("31-60 นาที หลังตื่นนอน", 0),
          Answer("มากกว่า 60 นาทีหลังตื่นนอน", 0)
        ]),
        Question("ท่านสูบบุหรี่จัดในช่วง 2-3 ชั่วโมงแรกหลังตื่นนอน ?", [
          Answer("ใช่", 1),
          Answer("ไม่ใช่", 0),
        ]),
        Question("คุณคิดว่าบุหรี่ม้วนไหนที่คุณไม่อยากเลิก ?", [
          Answer("มวนแรกตอนเช้า", 1),
          Answer("มวนอื่นๆ ระหว่างวัน", 0),
        ]),
        Question("คุณรู้สึกลำบากหรือยุ่งยากในเขตปลอดบุหรี่หรือไม่ ?", [
          Answer("รู้สึกลําบาก", 1),
          Answer("ไม่รู้สึกลําบาก", 0),
        ]),
        Question("คุณยังต้องสูบบุหรี่แม้จะเจ็บป่วยหรือนอนพักโรงพยาบาล ?", [
          Answer("ใช่", 3),
          Answer("ไม่ใช่", 1),
        ]),
        Question("ระยะเลิกบุหรี่ ?", [
          Answer("ไม่ต้องการเลิก", 3),
          Answer("คิดจะเลิก", 1),
          Answer("เตรียมที่จะเลิก", 0),
          Answer("กําลังเลิก", 0),
          Answer("เลิกได้แล้ว", 0),
        ]),
      ],
      Icons.smoke_free, 
    ),
  ];
}
