// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction.dart';
import '../models/client.dart';

class ApiService {
  final String baseUrl =
      'http://10.0.2.2/finpro_api/api.php?endpoint='; // تأكد من تغيير هذا إلى عنوان الخادم الصحيح

  // جلب قائمة العملاء مع الإجماليات
  Future<Map<String, dynamic>> fetchClientsWithTotals() async {
    final response =
    await http.get(Uri.parse('${baseUrl}clients_with_totals'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في جلب قائمة العملاء مع الإجماليات');
    }
  }

  // جلب قائمة العملاء
  Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('${baseUrl}clients'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب قائمة العملاء');
    }
  }

  // جلب تفاصيل عميل معين
  Future<Client> getClient(int clientId) async {
    final response =
    await http.get(Uri.parse('${baseUrl}clients&id=$clientId'));

    if (response.statusCode == 200) {
      return Client.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في جلب تفاصيل العميل');
    }
  }

  // جلب اسم العميل باستخدام clientId
  Future<String> getClientName(int clientId) async {
    final response =
    await http.get(Uri.parse('${baseUrl}clients&id=$clientId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('name')) {
        return data['name'];
      } else {
        throw Exception('فشل في جلب اسم العميل');
      }
    } else {
      throw Exception('فشل في جلب تفاصيل العميل');
    }
  }

  // إضافة عميل جديد
  Future<void> addClient(String name, String phone, String address) async {
    final response = await http.post(
      Uri.parse('${baseUrl}clients'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في إضافة العميل');
    }
  }

  // تحديث العميل
  Future<void> updateClient(
      int clientId, String name, String phone, String address) async {
    final response = await http.put(
      Uri.parse('${baseUrl}clients&id=$clientId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في تحديث العميل');
    }
  }

  // حذف العميل
  Future<void> deleteClient(int clientId) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}clients&id=$clientId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في حذف العميل');
    }
  }

  // جلب المعاملات الخاصة بعميل معين
  Future<List<Transaction>> fetchTransactions(int clientId) async {
    final response = await http.get(
        Uri.parse('${baseUrl}transactions&client_id=$clientId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب المعاملات');
    }
  }

  // جلب تفاصيل معاملة معينة
  Future<Transaction> getTransaction(int transactionId) async {
    final response = await http
        .get(Uri.parse('${baseUrl}transactions&id=$transactionId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      return Transaction.fromJson(jsonData);
    } else {
      throw Exception('فشل في جلب تفاصيل المعاملة');
    }
  }

  // إضافة معاملة مع صورة
  Future<void> addTransactionWithImage(
      int clientId,
      double amount,
      String details,
      String date,
      String type,
      String? imageBase64) async {
    try {
      Map<String, dynamic> payload = {
        'client_id': clientId,
        'amount': amount.toString(),
        'details': details,
        'date': date,
        'type': type,
      };

      if (imageBase64 != null) {
        payload['image_base64'] = imageBase64;
      }

      final response = await http.post(
        Uri.parse('${baseUrl}transactions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] != 'Transaction added successfully') {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('فشل في تسجيل المعاملة');
      }
    } catch (e) {
      throw Exception('Error uploading transaction: $e');
    }
  }

  // تحديث معاملة موجودة
  Future<void> updateTransaction(
      int transactionId,
      double amount,
      String details,
      String date,
      String type,
      String? imageBase64) async {
    try {
      Map<String, dynamic> payload = {
        'amount': amount.toString(),
        'details': details,
        'date': date,
        'type': type,
      };

      if (imageBase64 != null) {
        payload['image_base64'] = imageBase64;
      }

      final response = await http.put(
        Uri.parse('${baseUrl}transactions&id=$transactionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] != 'Transaction updated successfully') {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('فشل في تحديث المعاملة');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // حذف معاملة
  Future<void> deleteTransaction(int transactionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}transactions&id=$transactionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] != 'Transaction deleted successfully') {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('فشل في حذف المعاملة');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
}
