import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  List<Placemark> _enderecos = [];

  final TextEditingController _controllerSearch = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscar Endereços"),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child:  Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controllerSearch,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(16 , 8, 16, 8),
                          hintText: "Informe endereço",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white,),
                    onPressed: (){
                      _buscarEnderecos();
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: ListView.builder(
                  itemCount: _enderecos.length,
                  itemBuilder: (context, index){

                    Placemark endereco = _enderecos[index];
                    String full = "thoroughfare: ${endereco.thoroughfare}";
                    full += "\nsubLocality: ${endereco.subLocality}";
                    full += "\nsubThoroughfare: ${endereco.subThoroughfare}";
                    full += "\nadministrativeArea: ${endereco.administrativeArea}";
                    full += "\nlocality: ${endereco.locality}";
                    full += "\nsubAdministrativeArea: ${endereco.subAdministrativeArea}";
                    full += "\npostalCode: ${endereco.postalCode}";
                    full += "\nposition: ${endereco.position}";

                    String result = "${endereco.thoroughfare}";
                    result += " - ${endereco.administrativeArea}";
                    result += "\n${endereco.position}";

                    return Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(full),
                            onTap: (){
                              Navigator.of(context).pop({"position": endereco.position});
                            },
                          ) ,
                          Divider()
                        ]
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  void _buscarEnderecos() async {
    String endereco = _controllerSearch.text;
    await Geolocator().placemarkFromAddress(endereco).then((List<Placemark> placemark){
      setState(() {
        _enderecos = placemark;
        _controllerSearch.clear();
      });
    }).catchError((erro){
      _enderecos = List();
    });

  }
}
