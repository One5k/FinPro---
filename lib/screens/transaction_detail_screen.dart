// lib/screens/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import 'transaction_input_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  TransactionDetailScreen({required this.transactionId});

  @override
  _TransactionDetailScreenState createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  ApiService apiService = ApiService();
  bool isLoading = true;
  Transaction? transaction;

  String clientName = 'اسم العميل'; // متغير لاسم العميل

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<void> fetchTransactionDetails() async {
    try {
      Transaction data = await apiService.getTransaction(widget.transactionId);
      print("Fetched Transaction Data: $data"); // للتتبع

      // الحصول على اسم العميل باستخدام clientId
      String name = await apiService.getClientName(data.clientId);

      setState(() {
        transaction = data;
        clientName = name;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب تفاصيل المعاملة')),
      );
    }
  }

  void deleteTransaction() async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد أنك تريد حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('نعم'),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        await apiService.deleteTransaction(widget.transactionId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف المعاملة بنجاح')),
        );
        Navigator.pop(context, true); // العودة إلى الشاشة السابقة مع إشارة لإعادة التحميل
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المعاملة')),
        );
      }
    }
  }

  void editTransaction() async {
    if (transaction == null) return;

    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionInputScreen(
          clientId: transaction!.clientId,
          clientName: clientName, // تمرير اسم العميل
          transactionType: transaction!.type,
          transactionId: transaction!.id,
          existingTransaction: transaction, // تمرير كائن Transaction
        ),
      ),
    );

    if (result == true) {
      fetchTransactionDetails();
      Navigator.pop(context, true); // العودة مع إشارة لإعادة التحميل
    }
  }

  String getTransactionTypeLabel(String type) {
    if (type == 'مدين') {
      return 'له';
    } else if (type == 'دائن') {
      return 'عليه';
    } else {
      return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clientName), // عرض اسم العميل في الـ AppBar
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transaction == null
          ? Center(child: Text('لا توجد بيانات'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبلغ: ${transaction!.amount} ر.ي',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'التفاصيل: ${transaction!.details}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'التاريخ: ${transaction!.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'النوع: ${getTransactionTypeLabel(transaction!.type)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            transaction!.imagePath != null &&
                transaction!.imagePath!.isNotEmpty
                ? Center(
              child: GestureDetector(
                onTap: () {
                  // عرض الصورة في نافذة منبثقة
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Image.network(
                        'http://10.0.2.2/finpro_api/${transaction!.imagePath}',
                      ),
                    ),
                  );
                },
                child: Image.network(
                  'http://10.0.2.2/finpro_api/${transaction!.imagePath}',
                  height: 200,
                ),
              ),
            )
                : Container(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: editTransaction,
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: Text('تعديل',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: deleteTransaction,
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text('حذف',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
