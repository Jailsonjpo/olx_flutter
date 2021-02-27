import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_flutter/models/Anuncio.dart';
import 'package:olx_flutter/views/widgets/BotaoCustomizado.dart';
import 'package:olx_flutter/views/widgets/InputCustomizado.dart';
import 'package:validadores/validadores.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  List<File> _listaImagens = List();
  List<DropdownMenuItem<String>> _listaItensDropEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();
  final _formKey = GlobalKey<FormState>();
  Anuncio _anuncio;
  BuildContext _dialogContext;
  String _urlImagemRecuperada;

  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  final picker = ImagePicker();
  File imagemSelecionada;

  _selecionarImagemGaleria()async{

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    imagemSelecionada = File(pickedFile.path);

    if(imagemSelecionada != null){

      setState(() {
        _listaImagens.add(imagemSelecionada);
      });

    }
  }

  _abrirDialig(BuildContext context){

    showDialog(
        context: context,
       barrierDismissible: false,
      builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text("Salvando Anúncio...")

            ],),
          );
      }

    );
  }

  _salvarAnuncio() async{

    _abrirDialig(_dialogContext);

    //upload imagens no Storage
    await _uploadImagens();

  //  print ("lista imagens: ${_anuncio.fotos.toString()}");
    //Salvar anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
    .doc(idUsuarioLogado)
    .collection("anuncios")
    .doc(_anuncio.id)
    .set(_anuncio.toMap()).then((_){

      Navigator.pop(_dialogContext);
      Navigator.pop(context);

    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {

      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child(_anuncio.id)
          .child(nomeImagem + ".jpg");

      UploadTask uploadTask = arquivo.putFile(imagem);

      await uploadTask.whenComplete(() async{
        await arquivo.getDownloadURL().then((value){

          _anuncio.fotos.add(value);

         /*FirebaseFirestore db = FirebaseFirestore.instance;

          Map<String, dynamic> dadosAtualizar = {
            "fotos" : value
          };

          print("valor $value");
          db.collection("meus_anuncios").doc(_anuncio.id).update(dadosAtualizar);*/

        });

      });






      /*uploadTask.then((TaskSnapshot snapshot){
        _recuperarUrlImagem(snapshot);
      }).catchError((Object e) {
        print(e); // FirebaseException
        });*/


      /*TaskSnapshot taskSnapshot = await uploadTask.whenComplete((){

        taskSnapshot = taskSnaphot.ref.getDownloadUrl();

      }
*/

  //    );



      /*  String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child(_anuncio.id)
          .child(nomeImagem + ".jpg");

    UploadTask task = arquivo.putFile(imagem);







// Optional
    task.snapshotEvents.listen((TaskSnapshot snapshot) {
    setState(() {
    //_subindoImagem = true;
    });

    print('Snapshot state: ${snapshot.state}'); // paused, running, complete
    print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
    }, onError: (Object e) {
    print(e); // FirebaseException
    });

// Optional
    task.then((TaskSnapshot snapshot) {
  //  _subindoImagem = false;
    print('Upload complete!');
  //  _recuperarUrlImagem(snapshot);
    }).catchError((Object e) {
    print(e); // FirebaseException
    });*/

  }

  }

  /*Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    atualizarUrlImagemFirestore(url);

    *//*setState(() {
      _urlImagemRecuperada = url;
    });*//*
  }*/

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

   _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "fotos" : url
    };
    db.collection("meus_anuncios").doc(_anuncio.id).update(dadosAtualizar);
  }

 /* Future _uploadImagens() async{
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens){

      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child(_anuncio.id)
          .child(nomeImagem);

      UploadTask task = arquivo.putFile(imagem);

      task.then((TaskSnapshot snapshot) async {
        //_subindoImagem = false;
        print('Upload complete!');

        String url = await snapshot.ref.getDownloadURL();
        _anuncio.fotos.add(url);
        //_recuperarUrlImagem(snapshot);

      }).catchError((Object e) {
        print(e); // FirebaseException
      });

    }

  }*/

/*
  _selecionarImagemGaleria() async{
    */
/*final picker = ImagePicker();
    PickedFile imagemSelecionada2;
*//*

   // File imagemSelecionada;

    File imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
  //  File imagemSelecionada = (await ImagePicker().getImage(source: ImageSource.camera,)) as File;
  //   PickedFile imagemSelecionada2 = await picker.getImage(source: ImageSource.gallery);

   // imagemSelecionada = File(pickedFile.path);

    if (imagemSelecionada != null) {

      setState(() {
        _listaImagens.add(imagemSelecionada);
      });

    }

  }
*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }
  
  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias.add(
        DropdownMenuItem(child: Text("Automóvel"), value: "auto",)
    );

    _listaItensDropCategorias.add(
        DropdownMenuItem(child: Text("Imóvel"), value: "imovel",)
    );

    _listaItensDropCategorias.add(
        DropdownMenuItem(child: Text("Eletrônicos"), value: "eletro",)
    );

    _listaItensDropCategorias.add(
        DropdownMenuItem(child: Text("Moda"), value: "moda",)
    );

    _listaItensDropCategorias.add(
        DropdownMenuItem(child: Text("Esportes"), value: "esportes",)
    );

    //Estados
    
   for (var estado in Estados.listaEstadosSigla) {

     _listaItensDropEstados.add(
       DropdownMenuItem(child: Text(estado), value: estado,)
     );

   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo Anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //área de imagens
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: (imagens) {
                    if (imagens.length == 0) {
                      return "Necessário selecionar uma imagem!";
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      children: [
                        Container(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _listaImagens.length + 1,
                              itemBuilder: (context, indice) {

                                if (indice == _listaImagens.length) {
                                  return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(

                                      onTap: (){
                                        _selecionarImagemGaleria();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[400],
                                        radius: 50,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                              color: Colors.grey[100],
                                          ),
                                           Text(
                                             "Adicionar",
                                             style: TextStyle(
                                               color: Colors.grey[100]
                                             ),


                                          )
                                        ],

                                        ),
                                      ) ,

                                    ),

                                  );
                                }

                                if (_listaImagens.length > 0) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: (){

                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                              Image.file(_listaImagens[indice]),
                                              FlatButton(
                                                  child: Text("Excluir"),
                                                  textColor: Colors.red,
                                                  onPressed: (){
                                                    setState(() {
                                                      _listaImagens.removeAt(indice);
                                                      Navigator.of(context).pop();
                                                    });
                                                  }
                                              )
                                            ],),
                                        )
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 50,
                                          backgroundImage: FileImage(_listaImagens[indice]),
                                        child: Container(
                                          color: Color.fromRGBO(255, 255, 255, 0.4),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.delete, color: Colors.red,),
                                        ),
                                        
                                      ),


                                    ),

                                  );

                                }

                                return Container();

                              }),
                        ),
                        if (state.hasError)
                          Container(
                            child: Text(
                              "[${state.errorText}]",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                      ],
                    );
                  },
                ),

                //menu dropDown
                Row(
                  children: [
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoEstado,
                          hint: Text("Estados"),
                          onSaved: (estado){
                            _anuncio.estado = estado;
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20
                          ),
                          items: _listaItensDropEstados,
                          validator: (valor){
                            return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório").valido(valor);
                          },

                          onChanged: (valor){

                            setState(() {
                              _itemSelecionadoEstado = valor;
                            });

                          },
                        ) ,
                        ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoCategoria,
                          hint: Text("Categorias"),
                          onSaved: (categoria){
                            _anuncio.categoria = categoria;
                          },
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                          items: _listaItensDropCategorias,
                          validator: (valor){
                            return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório").valido(valor);
                          },

                          onChanged: (valor){

                            setState(() {
                              _itemSelecionadoCategoria = valor;
                            });

                          },
                        ) ,
                      ),
                    ),
                  ],
                ),

                //cx de texto e botoes

               Padding(
                 padding: EdgeInsets.only(bottom: 15, top: 15),
                 child:  InputCustomizado(
                   hint: "Título",
                   onSaved: (titulo){
                     _anuncio.titulo = titulo;
                   },
                   validator: (valor){
                     return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório").valido(valor);
                   },
                 ),
               ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child:  InputCustomizado(
                    hint: "Preço",
                    onSaved: (preco){
                      _anuncio.preco = preco;
                    },
                    type: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(centavos: true)
                    ],
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório").valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child:  InputCustomizado(
                    hint: "Telefone",
                    onSaved: (telefone){
                      _anuncio.telefone = telefone;
                    },
                    type: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório").valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child:  InputCustomizado(
                    hint: "Descrição (200 caracteres)",
                    onSaved: (descricao){
                      _anuncio.descricao = descricao;
                    },
                    maxLines: null,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                          .maxLength(200, msg: "Máximo de 200 caracteres")
                          .valido(valor);
                    },
                  ),
                ),

                BotaoCustomizado(
                  texto: "Cadastrar Anúncio",
                  onPressed: () {
                    if (_formKey.currentState.validate()) {

                      //Salva campos
                      _formKey.currentState.save();

                      //Configura dialog context
                      _dialogContext = context;

                      //Salvar anuncio
                      _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
