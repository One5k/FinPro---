// lib/screens/transaction_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // لاستخدام base64

class TransactionInputScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final String transactionType;
  final int? transactionId; // معرف المعاملة للتعديل
  final Transaction? existingTransaction; // بيانات المعاملة الحالية

  TransactionInputScreen({
    required this.clientId,
    required this.clientName,
    required this.transactionType,
    this.transactionId,
    this.existingTransaction,
  });

  @override
  _TransactionInputScreenState createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  ApiService apiService = ApiService();
  bool isLoading = false;
  File? _image;
  String? existingImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      amountController.text = widget.existingTransaction!.amount.toString();
      detailsController.text = widget.existingTransaction!.details;
      selectedDate = widget.existingTransaction!.date;
      existingImagePath = widget.existingTransaction!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context, // BuildContext الصحيح
      builder: (BuildContext bc) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile =
                await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('التقاط صورة'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile =
                await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, // BuildContext الصحيح
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String mimeType = '';
      String extension = imageFile.path.split('.').last.toLowerCase();
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
      return 'data:$mimeType;base64,$base64Image';
    } catch (e) {
      print("Error converting image to base64: $e");
      return null;
    }
  }

  void addOrUpdateTransaction() async {
    if (amountController.text.isEmpty || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    double? amount = double.tryParse(amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? imageBase64;
      if (_image != null) {
        imageBase64 = await _convertImageToBase64(_image!);
      }

      if (widget.transactionId == null) {
        // إضافة معاملة جديدة
        await apiService.addTransactionWithImage(
          widget.clientId,
          amount,
          detailsController.text,
          selectedDate.toIso8601String().split('T')[0],
          widget.transactionType,
          imageBase64,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسجيل المعاملة بنجاح')),
        );
      } else {
        // تعديل معاملة موجودة
        await apiService.updateTransaction(
          widget.transactionId!,
          amount,
          detailsController.text,
          selectedDate.toIso8601String().split('T')[0],
          widget.transactionType,
          imageBase64,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تعديل المعاملة بنجاح')),
        );
      }

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true); // تمرير قيمة لإعلام الشاشة السابقة بإعادة التحميل
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      // عرض رسالة خطأ للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تسجيل المعاملة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clientName, // عرض اسم العميل في الـ AppBar
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // استخدام SingleChildScrollView لتجنب مشاكل overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل إدخال المبلغ
            Center(
              child: TextField(
                controller: amountController,
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 48, color: Colors.green),
                decoration: InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            // اختيار التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style:
                  TextStyle(fontSize: 18, color: Colors.blue),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context); // تمرير 'BuildContext' الصحيح
                  },
                ),
              ],
            ),
            Divider(),
            // إدخال التفاصيل
            TextField(
              controller: detailsController,
              decoration: InputDecoration(
                labelText:
                "التفاصيل (البضاعة، الكمية، رقم الفاتورة)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            // زر إضافة صورة
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt, color: Colors.blue),
              label: Text("إضافة صورة",
                  style: TextStyle(color: Colors.blue)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 10),
            // عرض الصورة المختارة أو الصورة الحالية
            _image != null
                ? Center(
              child: Image.file(
                _image!,
                height: 200,
              ),
            )
                : existingImagePath != null &&
                existingImagePath!.isNotEmpty
                ? Center(
              child: GestureDetector(
                onTap: () {
                  // عرض الصورة في نافذة منبثقة
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Image.network(
                        'http://10.0.2.2/finpro_api/$existingImagePath',
                      ),
                    ),
                  );
                },
                child: Image.network(
                  'http://10.0.2.2/finpro_api/$existingImagePath',
                  height: 200,
                ),
              ),
            )
                : Container(),
            SizedBox(height: 20),
            // زر تسجيل أو تعديل
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addOrUpdateTransaction,
                child: Text(widget.transactionId == null
                    ? "تسجيل"
                    : "تعديل"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
