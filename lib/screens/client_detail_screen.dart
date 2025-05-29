// lib/screens/client_detail_screen.dart

import 'package:flutter/material.dart';
import 'transaction_input_screen.dart';
import 'transaction_detail_screen.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import '../models/client.dart';

class ClientDetailScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final double balance;

  ClientDetailScreen({
    required this.clientId,
    required this.clientName,
    required this.balance,
  });

  @override
  _ClientDetailScreenState createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  List<Transaction> transactions = [];
  ApiService apiService = ApiService();
  bool isLoading = true;
  double balance = 0.0;

  bool dataChanged = false; // متغير لتتبع التغييرات

  @override
  void initState() {
    super.initState();
    balance = widget.balance;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      List<Transaction> data =
      await apiService.fetchTransactions(widget.clientId);
      Client clientData = await apiService.getClient(widget.clientId);

      setState(() {
        transactions = data;
        balance = clientData.balance;
        isLoading = false;
      });

      dataChanged = true; // تعيين dataChanged إلى true عند حدوث تغيير
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب المعاملات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, dataChanged); // تمرير dataChanged عند العودة
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.clientName,
            style: TextStyle(color: Colors.blue),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link, color: Colors.blue),
                SizedBox(width: 20),
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 20),
                Icon(Icons.note, color: Colors.blue),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الرصيد",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$balance ر.ي",
                    style: TextStyle(
                      fontSize: 18,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.archive, color: Colors.blue),
              title: Text("الأرشيف"),
              subtitle: Text("${transactions.length} معاملات"),
              trailing:
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                // إمكانية إضافة شاشة للأرشيف لاحقًا
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                child: Text("لا توجد أي معاملة"),
              )
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    leading: transaction.type == 'مدين'
                        ? Icon(Icons.arrow_upward,
                        color: Colors.green)
                        : Icon(Icons.arrow_downward,
                        color: Colors.red),
                    title: Text("${transaction.amount} ر.ي"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.details),
                        SizedBox(height: 5),
                        transaction.imagePath != null &&
                            transaction.imagePath!.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            // الانتقال إلى شاشة تفاصيل المعاملة
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TransactionDetailScreen(
                                      transactionId:
                                      transaction.id,
                                    ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                fetchTransactions(); // إعادة جلب المعاملات بعد الحذف أو التعديل
                              }
                            });
                          },
                          child: Image.network(
                            'http://10.0.2.2/finpro_api/${transaction.imagePath}',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(),
                      ],
                    ),
                    trailing: Text(
                      "${transaction.date.toLocal()}".split(' ')[0],
                    ),
                    onTap: () {
                      // الضغط على السطر للتنقل إلى تفاصيل المعاملة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionDetailScreen(
                                transactionId: transaction.id,
                              ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          fetchTransactions(); // إعادة جلب المعاملات بعد الحذف أو التعديل
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionInputScreen(
                              clientId: widget.clientId,
                              clientName: widget.clientName,
                              transactionType: "مدين",
                              transactionId: null,
                              existingTransaction: null,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            fetchTransactions();
                          }
                        });
                      },
                      child: Text("له"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        padding:
                        EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionInputScreen(
                              clientId: widget.clientId,
                              clientName: widget.clientName,
                              transactionType: "دائن",
                              transactionId: null,
                              existingTransaction: null,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            fetchTransactions();
                          }
                        });
                      },
                      child: Text("عليه"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        padding:
                        EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
