import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dio_instance.dart';

class ChatService {

  Dio api = configureDio();

  Future<Map<String, dynamic>> create (Map<String, dynamic> data) async{

    final pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    if (token != "") {
      api.options.headers['AUTHORIZATION'] = 'Bearer $token';
    }

    final response = await api.post('immobilierpannehelper/discussion/', data: data);

    return response.data;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    if (token != "") {
      api.options.headers['AUTHORIZATION'] = 'Bearer $token';
    }

    try {
      final response = await api.get('immobilierpannehelper/discussion/');

      // Vérifier si response.data est bien une liste
      if (response.data is List) {
        // Si c'est une liste, la convertir en List<Map<String, dynamic>>
        return (response.data as List)
            .map((item) => item as Map<String, dynamic>) // On s'assure que chaque élément est un Map
            .toList();
      } else {
        // Si ce n'est pas une liste, lever une exception
        throw Exception("Données non conformes reçues de l'API : ${response.data}");
      }
    } catch (error) {
      print("Erreur lors de la récupération des messages : $error");
      throw error; // Vous pouvez propager l'erreur ou gérer selon vos besoins
    }
  }

}