// lib/screens/edit_client_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/client.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

   const EditClientScreen({required this.client});

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  ApiService apiService = ApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعبئة الحقول ببيانات العميل الحالي
    nameController.text = widget.client.name;
    phoneController.text = widget.client.phone;
    addressController.text = widget.client.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تعديل عميل",
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            buildInputField("الاسم", "الاسم", nameController),
            buildInputField("رقم الهاتف", "رقم الهاتف", phoneController),
            buildInputField("العنوان", "العنوان", addressController),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  updateClient();
                },
                child: Text("تعديل"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  void updateClient() async {
    nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ;

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.updateClient(
        widget.client.id,
        nameController.text,
        phoneController.text,
        addressController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تعديل العميل بنجاح')),
      );
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true); // إبلاغ الشاشة السابقة لإعادة التحميل
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تعديل العميل')),
      );
    }
  }

  Widget buildInputField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
