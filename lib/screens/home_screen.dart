// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart'; // إضافة هذا السطر
import 'client_detail_screen.dart';
import '../widgets/client_tile.dart';
import '../widgets/debt_info_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<_ClientsScreenState> clientsScreenKey =
  GlobalKey<_ClientsScreenState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.contacts, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'انس',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'العملاء'),
              Tab(text: 'الموردين'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClientsScreen(key: clientsScreenKey),
            SuppliersScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddClientScreen()),
            ).then((value) {
              if (value == true) {
                clientsScreenKey.currentState?.fetchClients();
              }
            });
          },
          child: Icon(Icons.person_add),
          backgroundColor: Colors.blue,
          tooltip: 'إضافة عميل جديد',
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: "المزيد",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "دفتر النقدية",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "دفتر الديون",
            ),
          ],
        ),
      ),
    );
  }
}

class SuppliersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "الموردين",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ClientsScreen extends StatefulWidget {
  ClientsScreen({Key? key}) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];
  ApiService apiService = ApiService();
  bool isLoading = true;
  double totalGiven = 0.0;
  double totalTaken = 0.0;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Client> data = await apiService.fetchClients();
      Map<String, dynamic> totals = await apiService.fetchClientsWithTotals();

      setState(() {
        clients = data;
        totalGiven = totals['total_given'] != null
            ? double.parse(totals['total_given'].toString())
            : 0.0;
        totalTaken = totals['total_taken'] != null
            ? double.parse(totals['total_taken'].toString())
            : 0.0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب قائمة العملاء')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
      children: [
        SizedBox(height: 10),
        // معلومات الديون الإجمالية
        DebtInfoWidget(
          givenAmount: "$totalGiven ر.ي",
          takenAmount: "$totalTaken ر.ي",
        ),
        // عرض عدد العملاء
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'العملاء (${clients.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // قائمة العملاء
        Expanded(
          child: clients.isEmpty
              ? Center(child: Text("لا توجد عملاء"))
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              double balance = client.balance;
              return ListTile(
                title: Text(
                  client.name,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "منذ ${client.daysAgo} أيام",
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  "${client.balance} ر.ي",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                    balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                leading: CircleAvatar(
                  child: Text(client.name[0]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailScreen(
                        clientId: client.id,
                        clientName: client.name,
                        balance: balance,
                      ),
                    ),
                  ).then((value) {
                    if (value == true) {
                      fetchClients(); // تحديث البيانات عند العودة
                    }
                  });
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading:
                            Icon(Icons.edit, color: Colors.blue),
                            title: Text('تعديل'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditClientScreen(client: client),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  fetchClients(); // تحديث القائمة بعد التعديل
                                }
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('حذف'),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('تأكيد الحذف'),
                                  content: Text(
                                      'هل أنت متأكد أنك تريد حذف هذا العميل؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: Text('لا'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        try {
                                          await apiService
                                              .deleteClient(client.id);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'تم حذف العميل بنجاح')),
                                          );
                                          fetchClients(); // تحديث القائمة بعد الحذف
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'فشل في حذف العميل')),
                                          );
                                        }
                                      },
                                      child: Text('نعم'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
