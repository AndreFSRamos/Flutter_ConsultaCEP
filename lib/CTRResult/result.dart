import '../Model/model_cep.dart';
import 'package:http/http.dart' as http;

class ViaCepService {
  static Future<ResultCep> fetchCep(String cep) async {
    var request = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    final response = await http.get(request);
    if (response.statusCode == 200) {
      return ResultCep.fromJson(response.body);
    } else {
      throw Exception('Requisição inválida!');
    }
  }
}
