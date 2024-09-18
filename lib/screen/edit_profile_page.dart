import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'ChangePasswordPage.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  EditProfilePage({
    required this.profileData,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  List<String> provinces = [];
  List<String> districts = [];
  List<String> subdistricts = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubdistrict;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.profileData);

    // Initialize the date controller
    _dateController.text = _formData['date_birth'] != null
        ? DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(_formData['date_birth']))
        : '';

    fetchProvinces(); // Fetch provinces when the page is initialized
  }

  String? _validateThaiText(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final thaiRegex = RegExp(r'^[ก-๙]+$');
    if (!thaiRegex.hasMatch(value)) {
      return 'กรุณากรอกเป็นภาษาไทยเท่านั้น';
    }
    return null;
  }

  String? _validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเลขบัตรประชาชน';
    }
    final idCardRegex = RegExp(r'^\d{1}-\d{4}-\d{5}-\d{2}-\d{1}$');
    if (!idCardRegex.hasMatch(value)) {
      return 'รูปแบบเลขบัตรประชาชนไม่ถูกต้อง';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทร';
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
    }
    return null;
  }

  String? _validateNumberAndSlash(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    // กำหนดรูปแบบ Regular Expression ให้ตรวจสอบเฉพาะตัวเลขและเครื่องหมาย /
    final numberAndSlashRegex = RegExp(r'^[0-9/]+$');
    if (!numberAndSlashRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะบ้านเลขที่เท่านั้น';
    }
    return null;
  }

  String? _validateRoad(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final thaiRegex = RegExp(r'^[ก-๙\-s]+$');
    if (!thaiRegex.hasMatch(value)) {
      return 'กรุณากรอกเป็นภาษาไทยเท่านั้น';
    }
    return null;
  }

  String? _validateNumberOnly(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    // กำหนดรูปแบบ Regular Expression ให้ตรวจสอบเฉพาะตัวเลขเท่านั้น
    final numberOnlyRegex = RegExp(r'^[0-9-]+$');
    if (!numberOnlyRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลขเท่านั้น';
    }
    return null;
  }

  Future<void> fetchProvinces() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.110.211:3000/provinces'));
      if (response.statusCode == 200) {
        setState(() {
          provinces = List<String>.from(json.decode(response.body));
          selectedProvince = _formData['province'];
          if (selectedProvince != null) {
            fetchDistricts(selectedProvince!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลจังหวัดได้')),
      );
    }
  }

  Future<void> fetchDistricts(String province) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.110.211:3000/districts/$province'));
      if (response.statusCode == 200) {
        setState(() {
          districts = List<String>.from(json.decode(response.body));
          selectedDistrict = null; // Reset district when province changes
          selectedSubdistrict = null; // Reset subdistrict when province changes
          subdistricts = []; // Clear subdistricts list
          selectedDistrict = _formData['district'];
          if (selectedDistrict != null) {
            fetchSubdistricts(selectedDistrict!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลอำเภอได้')),
      );
    }
  }

  Future<void> fetchSubdistricts(String district) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.110.211:3000/subdistricts/$district'));
      if (response.statusCode == 200) {
        setState(() {
          subdistricts = List<String>.from(json.decode(response.body));
          selectedSubdistrict = null; // Reset subdistrict when district changes
          selectedSubdistrict = _formData['subdistrict'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลตำบลได้')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure the form data has the correct values before saving
      _formData['province'] = selectedProvince;
      _formData['district'] = selectedDistrict;
      _formData['subdistrict'] = selectedSubdistrict;

      // Convert date_birth to B.E. format if necessary
      if (_formData['date_birth'] != null &&
          _formData['date_birth'].isNotEmpty) {
        final date = DateTime.parse(_formData['date_birth']);
        final buddhistYear = date.year + 543;
        _formData['date_birth'] = DateFormat('yyyy-MM-dd')
            .format(DateTime(buddhistYear, date.month, date.day));
      }

      try {
        print(_formData); // Print the data before sending
        final response = await http.put(
          Uri.parse('http://192.168.110.211:3000/profile/${_formData['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_formData),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(
              context, _formData); // Send data back to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFF2A6F97),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdownFormField(
                    'title_name', 'คำนำหน้า', ['นาย', 'นาง', 'นางสาว']),
                _buildTextFormField('first_name', 'ชื่อ', validator: _validateThaiText),
                _buildTextFormField('last_name', 'นามสกุล', validator: _validateThaiText),
                _buildTextFormField('id_card', 'เลขบัตรประชาชน',validator: _validateIdCard),
                _buildTextFormField('phone', 'เบอร์โทร',validator: _validatePhone),
                _buildDropdownFormField(
                    'gender', 'เพศ', ['ชาย', 'หญิง', 'อื่นๆ']),
                GestureDetector(
                  onTap: () async {
                    // Parse the existing date from the controller, if available
                    DateTime? initialDate;
                    if (_dateController.text.isNotEmpty) {
                      // Try parsing the date in B.E. format (dd/MM/yyyy)
                      try {
                        final parts = _dateController.text.split('/');
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]) -
                            543; // Convert B.E. year to A.D.
                        initialDate = DateTime(year, month, day);
                      } catch (e) {
                        initialDate =
                            DateTime.now(); // Fallback to current date
                      }
                    } else {
                      initialDate = DateTime
                          .now(); // Default to current date if no date is set
                    }

                    final selectedDate = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DatePickerDialog(
                          initialYear: initialDate!.year,
                          initialMonth: initialDate.month,
                          initialDay: initialDate.day,
                        );
                      },
                    );

                    if (selectedDate != null) {
                      setState(() {
                        // Convert the selected date to B.E. format
                        final buddhistYear = selectedDate.year + 543;
                        final formattedDate = DateFormat('dd/MM/yyyy').format(
                            DateTime(buddhistYear, selectedDate.month,
                                selectedDate.day));

                        _dateController.text = formattedDate;
                        // Store the A.D. format date in _formData for backend purposes
                        _formData['date_birth'] =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'วันเกิด (วัน/เดือน/ปี)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกวันเกิด';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextFormField('house_number', 'เลขบ้าน',validator: _validateNumberAndSlash),
                _buildTextFormField('street', 'ถนน',validator: _validateRoad),
                _buildTextFormField('village', 'หมู่บ้าน',validator: _validateNumberOnly),

                // Province Dropdown
                _buildDropdownFormFieldWithApi(
                  'province',
                  'จังหวัด',
                  provinces,
                  provinces.contains(selectedProvince)
                      ? selectedProvince
                      : null, // Check if value is in the list
                  (value) {
                    setState(() {
                      selectedProvince = value;
                      selectedDistrict =
                          null; // Reset district when province changes
                      selectedSubdistrict =
                          null; // Reset subdistrict when province changes
                      fetchDistricts(value!);
                    });
                  },
                ),
// District Dropdown
                _buildDropdownFormFieldWithApi(
                  'district',
                  'อำเภอ',
                  districts,
                  districts.contains(selectedDistrict)
                      ? selectedDistrict
                      : null, // Check if value is in the list
                  (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedSubdistrict =
                          null; // Reset subdistrict when district changes
                      fetchSubdistricts(value!);
                    });
                  },
                ),

// Subdistrict Dropdown
                _buildDropdownFormFieldWithApi(
                  'subdistrict',
                  'ตำบล',
                  subdistricts,
                  subdistricts.contains(selectedSubdistrict)
                      ? selectedSubdistrict
                      : null, // Check if value is in the list
                  (value) {
                    setState(() {
                      selectedSubdistrict = value;
                      _formData['subdistrict'] = value;
                    });
                  },
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    int userId = int.parse(_formData['id'].toString());

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordPage(userId: userId),
                      ),
                    );
                  },
                  child: Text(
                    'แก้ไขรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Color(0xFF2A6F97),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'บันทึกข้อมูลส่วนตัว',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Color(0xFF2A6F97),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String key, String label,
      {bool isNumeric = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: _formData[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: (value) {
          setState(() {
            _formData[key] = value;
          });
        },
        onSaved: (value) {
          _formData[key] = value;
        },
        validator: validator,  // ใช้ validator
      ),
    );
  }

  Widget _buildDropdownFormField(String key, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _formData[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[key] = value;
          });
        },
        onSaved: (value) {
          _formData[key] = value;
        },
      ),
    );
  }

  Widget _buildDropdownFormFieldWithApi(
      String key,
      String label,
      List<String> items,
      String? selectedItem,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'กรุณาเลือก $label' : null,
      ),
    );
  }
}

class DatePickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int initialDay;

  DatePickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
  });

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  @override
  void initState() {
    super.initState();
    // Convert initial year from A.D. to B.E.
    selectedYear = widget.initialYear + 543;
    selectedMonth = widget.initialMonth;
    selectedDay = widget.initialDay;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('เลือกวันที่', style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(100, (index) {
                    final year =
                        2567 - index; // B.E. years (e.g., 2567, 2566, etc.)
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text(month.toString().padLeft(2, '0')),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: selectedDay,
                  items: List.generate(31, (index) {
                    final day = index + 1;
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text(day.toString().padLeft(2, '0')),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Return the selected date as is, keeping the B.E. year
                final selectedDate =
                    DateTime(selectedYear - 543, selectedMonth, selectedDay);
                Navigator.pop(context, selectedDate);
              },
              child: Text('ตกลง'),
            ),
          ],
        ),
      ),
    );
  }
}
