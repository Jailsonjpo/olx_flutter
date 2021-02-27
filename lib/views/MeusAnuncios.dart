import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx_flutter/models/Anuncio.dart';
import 'package:olx_flutter/views/widgets/ItemAnuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  Future _recuperaDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    await _recuperaDadosUsuarioLogado();
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _removerAnuncio(String idAnuncio){

    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .doc(idAnuncio)
        .delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: [Text("Carregando Anúncios"), CircularProgressIndicator()],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Anúncios"),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDados;
              break;
            case ConnectionState.active:
            case ConnectionState.done:

              //Exibe mensgem de erro
              if (snapshot.hasError) return Text("Erro ao carregadr os Dados!");

              QuerySnapshot querySnapshot = snapshot.data;

              return ListView.builder(
                itemCount: querySnapshot.docs.length,
                itemBuilder: (_, indice) {
                  List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                  DocumentSnapshot documentSnapshot = anuncios[indice];

                //  print("informaçoes snapshot: $documentSnapshot" );

                  Anuncio anuncio =
                      Anuncio.fromDocumentSnapshot(documentSnapshot);
                  return ItemAnuncio(
                    anuncio: anuncio,
                    onPressedRemover: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Confirmar"),
                              content:
                                  Text("Deseja realmente excluir o anúncio?"),
                              actions: [
                                FlatButton(
                                  child: Text(
                                    "Cancelar",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),

                                FlatButton(
                                  color: Colors.red,
                                  child: Text("Remover", style: TextStyle(color: Colors.white),),
                                  onPressed: (){
                                    _removerAnuncio(anuncio.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  );
                },
              );
          }

          return Container();
        },
      ),
    );
  }
}
