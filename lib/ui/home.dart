import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gifs_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Variavel search serve para armazenado a pesquisa do usuario.
  String _search = "";
  //Varialvel _offset serve para controlar a quandida de gifs que aparece na tela por vez.
  int _offset = 0;

  //Função para fazer as requisições da API, se _search for igual a ("") ira retornar os 25 GIFs
  //mais polulares atualmente. Caso o controlario ira retorar o resultado da pesquisa do usario, passando
  //as variaveis _search e _offset na URL da API. Retorna o resultado como Json.
  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == "") {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=l931EzdOqB50Wz7g7L8OXDKI7AeDBnf0&limit=25&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=l931EzdOqB50Wz7g7L8OXDKI7AeDBnf0&q=$_search&limit=19&offset=$_offset&rating=g&lang=en"));
    }

    return json.decode(response.body);
  }

  //Função init para efetuar a requisição ao startar a apalicação.
  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {});
  }

  //Corpo da aplicação.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("GIF's"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (texto) {
                //Função para iniciar um requisição com a pesquisa do usuario.
                //a variacel _search recebe o texto que o usário digita, e em
                //seguida reseta a varial _offset para novos gifs da pesquisa.
                setState(() {
                  _search = texto;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      //Chamando o Widget que retorno a grade de GIF's.
                      return _createTableGifs(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //Função para controlar o botão de carregar mais GIFs da pesquisa.
  //Se _search por igual a ("") ira apenas retornar os GIFs mais populares, e o
  //botão de carregar mais, não ira aparecer.
  //Caso contrario retornar o resultado da pesquisa, e incluira mais um espaço
  // para incluir o botão de carregar mais.
  int _getCount(List data) {
    if (_search == "") {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  _createTableGifs(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        List teste = snapshot.data["data"];
        if (_search == "" || index < teste.length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              //Ao clicar no GIF o usuario sera levado para outra tela onde mostrara apenas o GIF selecionado,
              //e também tem o botão de compartilhar.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data["data"][index]),
                ),
              );
            },
            onLongPress: () {
              //Ao precionar o clique em cima do GIF, ira aparecer as opções de compartilhamento.
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  "Carregar mais...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            //Ao clicar no botão carregar mais, e feita uma requisição de mais 19 GIF's, é necessario
            //que seja 19 para que sobre 1 espaço para incluir o botão de carregar mais.
            onTap: () {
              setState(
                () {
                  _offset += 19;
                },
              );
            },
          );
        }
      },
    );
  }
}
