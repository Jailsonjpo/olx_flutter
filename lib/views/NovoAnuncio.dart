import 'package:flutter/material.dart';
import 'package:olx_flutter/views/widgets/BotaoCustomizado.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  final _formKey = GlobalKey<FormState>();

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
              //TextFormField(),

              //menu dropDown
              Row(children: [
                Text("Estado"),
                Text("Categoria"),
              ],),
              
              //cx de texto e botoes
              Text("Caixas de Textos"),
              BotaoCustomizado(
                texto: "Cadastrar Anúncio",
                onPressed: (){

                  if (_formKey.currentState.validate()) {

                  }

                },
              ),

            ],),



          ),
        ),

      ),
    );
  }
}
