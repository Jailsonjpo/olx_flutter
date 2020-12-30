import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  List<String> itensMenu = ["", ""];

  _escolhaMenuItem(String itemEscolhido){

    switch(itemEscolhido){

      case "Meus Anúncios" :
        Navigator.pushNamed(context, "/meus-anuncios");
        break;

      case "Entrar / Cadastrar":
        Navigator.pushNamed(context, "/login");
        break;

      case "Deslogar" :
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, "/login");

  }

  Future _verificaUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    //User usuarioLogado = await auth.currentUser;

    if (auth.currentUser == null) {
      itensMenu = [
        "Entrar / Cadastrar"
      ];

    }else{
      itensMenu = [
    "Meus Anúncios", "Deslogar"
    ];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificaUsuarioLogado();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(
                      value: item,
                      child: Text(item),);
                }).toList();
              },
          )
        ],
      ) ,
      body: Container(
        child: Text("Anúncios") ,
      ),

    );
  }
}
