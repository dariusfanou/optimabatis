import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dio_instance.dart';

class PubService {

  Dio api = configureDio();

  Future<List<Map<String, dynamic>>> getAll() async {
    final pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    if (token != "") {
      api.options.headers['AUTHORIZATION'] = 'Bearer $token';
    }

    try {
      final response = await api.get('immobilierpannehelper/pubalistretriev/');

      // Vérifier si response.data est bien une liste
      if (response.data["results"] is List) {
        // Si c'est une liste, la convertir en List<Map<String, dynamic>>
        return (response.data["results"] as List)
            .map((item) => item as Map<String, dynamic>) // On s'assure que chaque élément est un Map
            .toList();
      } else {
        // Si ce n'est pas une liste, lever une exception
        throw Exception("Données non conformes reçues de l'API : ${response.data}");
      }
    } catch (error) {
      print("Erreur lors de la récupération des publicités : $error");
      throw error; // Vous pouvez propager l'erreur ou gérer selon vos besoins
    }
  }

}