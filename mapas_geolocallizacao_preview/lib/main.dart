import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_geolocallizacao_preview/search_page.dart';

void main() => runApp(MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marcadores = Set();
  Set<Polygon> _polygons = Set();
  Set<Polyline> _polylines = Set();

  bool _isServiceActive = false;

  Color _activeButtonColor = Colors.white;
  bool _buttonPressed = false;

  var _mapType = MapType.normal;
  int _mapListPosition = 0;
  List _maps = [
    MapType.normal,
    MapType.satellite,
    MapType.hybrid,
    MapType.terrain
  ];

  int _markPosition = 0;

  double _defaultTilt = 0.0;
  double _defaultBearing = 0.0;
  bool _rastrearPosicao = false;
  double _defaultZoom = 16.0;
  double _atualZoom = 16.0;
  //Av. Paulista local
  LatLng _posicaoTesteInicial = LatLng(-23.562436, -46.655005);
  LatLng _posicaoAtual = LatLng(-23.562436, -46.655005);
  double _marginRight = 7.0;

  void _clearAll() {
    setState(() {
      _polylines = Set();
      _polygons = Set();
      _atualZoom = _defaultZoom;
      _defaultTilt = 0.0;
      _defaultBearing = 0.0;
      _wideView = false;
      _rastrearPosicao = false;
      _moveCamera();
    });
  }

  void _tracarPolygons() {
    List<LatLng> marcadores = _marcadores.map((mark) => mark.position).toList();
    var polygon = Polygon(
        polygonId: PolygonId("Polygons ID"),
        strokeColor: Colors.red,
        fillColor: Color.fromRGBO(52, 113, 235, 0.2),
        points: marcadores,
        strokeWidth: 7,
        consumeTapEvents: true,
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: 60.0,
                  child: Center(
                    child: Text("Clicou na Area dos Polygons"),
                  ),
                );
              });
        });
    setState(() {
      _polygons.add(polygon);
    });
  }

  void _tracarPolylines() {
    List<LatLng> marcadores = _marcadores.map((mark) => mark.position).toList();
    var polys = Polyline(
        polylineId: PolylineId("Polylines ID"),
        color: Colors.green,
        width: 5,
        points: marcadores,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap,
        jointType: JointType.bevel);
    setState(() {
      _polylines.add(polys);
    });
  }

  void _fixPosition(Position posicao) {
    setState(() {
      _posicaoAtual = LatLng(posicao.latitude, posicao.longitude);
      _adicionarMarcador(LatLng(posicao.latitude, posicao.longitude));
      _goToLocation(LatLng(posicao.latitude, posicao.longitude));
    });
  }

  _goToLocation(LatLng position) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: _atualZoom)));
    if(!_rastrearPosicao){
      setState(() {
        _posicaoAtual = position;
        _atualZoom = _defaultZoom;
      });
    }
  }

  void _changeMapType() {
    if (_mapListPosition < _maps.length - 1) {
      _mapListPosition += 1;
      if (_mapListPosition > _maps.length - 1) {
        _mapListPosition = 0;
      }
    } else {
      _mapListPosition = 0;
    }
    setState(() {
      _mapType = _maps[_mapListPosition];
    });
  }

  _moveCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: _posicaoAtual,
            zoom: _atualZoom,
            tilt: _defaultTilt, //muda angulo camera
            bearing: _defaultBearing //Rotaciona camera
            )));
  }

  Future<Position> _recuperarLocalizacaoUsuarioDevice() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    _fixPosition(position);
    return position;
  }

  _adicionaListenerLocalizacao() async {
    var geolocator = Geolocator();
    var gpsAtivo = await geolocator.isLocationServiceEnabled();
    print("LocationService Ativo: $gpsAtivo");
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);

    setState(() {
      _isServiceActive = gpsAtivo;
    });

    if (gpsAtivo) {
      geolocator.getPositionStream(locationOptions).listen((Position position) {
        print("Listen...");
        if (_rastrearPosicao) {
          print("Rastreando posicao...");
          _goToLocation(LatLng(position.latitude, position.longitude));
        }
      });
      _adicionarMarcador(_posicaoTesteInicial);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("LocationService Inativo"),
              content: Text("talvez deveria ativar GPS para utilizar App."),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  void _adicionarMarcador(LatLng latLng) {
    setState(() {
      _marcadores.add(Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow: InfoWindow(title: latLng.toString())));
    });
  }

  void _changePosition() {
    if (_markPosition >= 0) {
      _goToLocation(_marcadores.toList()[_markPosition].position);
      setState(() {
        _markPosition += 1;
      });
      if (_markPosition > _marcadores.length - 1) {
        setState(() {
          _markPosition = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
//    print("Carregando marcadores...");
//    _carregarMarcadores();
    print("Ler localizacao atual do device do usuario....");
    _recuperarLocalizacaoUsuarioDevice();
    print("Adicionando listener de localizacao...");
    _adicionaListenerLocalizacao();
  }

  Future _searchResult() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SearchPage()));
    if (results != null && results.containsKey("position")) {
      Position p = results["position"];
      setState(() {
        _goToLocation(LatLng(p.latitude, p.longitude));
        _fixPosition(p);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapas e Geolocalização"),
        elevation: 0.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        backgroundColor: Colors.red,
        onPressed: () {
//          Navigator.push(context, MaterialPageRoute(
//            builder: (context) => SearchPage()
//          ));
          _searchResult();
        },
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "LocationService Ativo: ",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                    Text(
                      _isServiceActive.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                    Text(" / ", style: TextStyle(color: Colors.white, fontSize: 12.0)),
                    Text("Map Type: ", style: TextStyle(color: Colors.white, fontSize: 12.0)),
                    Text(_mapType.toString(), style: TextStyle(color: Colors.greenAccent, fontSize: 12.0))
                  ],
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                mapType: _mapType,
                initialCameraPosition:
                    CameraPosition(target: _posicaoAtual, zoom: _atualZoom),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                //myLocationButtonEnabled: true,
                markers: _marcadores,
                polygons: _polygons,
                polylines: _polylines,
                onLongPress: (latLng) {
                  _adicionarMarcador(latLng);
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
              height: 75.0,
              decoration: BoxDecoration(color: ThemeData.light().primaryColor),
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _zoomIn();
                            },
                          ),
                          Text("Zoom In", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                   Padding(
                     padding: EdgeInsets.only(right: _marginRight),
                     child:  Column(
                       children: <Widget>[
                         IconButton(
                           icon: Icon(
                             Icons.zoom_out,
                             color: Colors.white,
                           ),
                           onPressed: () {
                             _zoomOut();
                           },
                         ),
                         Text("Zoom Out", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                       ],
                     ),
                   ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.history,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _rotateCameraLeft();
                            },
                          ),
                          Text("Rot L", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.update,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _rotateCAmeraRight();
                            },
                          ),
                          Text("Rot R", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _anglePlus();
                            },
                          ),
                          Text("+45°", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _angleMinus();
                            },
                          ),
                          Text("-45°", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.map,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _changeMapType();
                            },
                          ),
                          Text("Map Type", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.golf_course,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _changePosition();
                            },
                          ),
                          Text("Locations", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.directions_run,
                              color: _activeButtonColor,
                            ),
                            onPressed: () {
                              _buttonPressed = !_buttonPressed;
                              setState(() {
                                if (_buttonPressed) {
                                  _rastrearPosicao = true;
                                  _activeButtonColor = Colors.red;
                                } else {
                                  _rastrearPosicao = false;
                                  _activeButtonColor = Colors.white;
                                }
                              });
                            },
                          ),
                          Text("Track", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.call_made,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _tracarPolylines();
                            },
                          ),
                          Text("Polylines", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.details,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _tracarPolygons();
                            },
                          ),
                          Text("Polygons", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _visualizacaoAmpla();
                              });
                            },
                          ),
                          Text("View", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: _marginRight),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _clearAll();
                            },
                          ),
                          Text("Reset", style: TextStyle(fontSize: 10.0, color: Colors.white),)
                        ],
                      ),
                    ),

                  ],
                ),
              )),
        ),
      ),
    );
  }

  void _rotateCameraLeft() {
    setState(() {
      _defaultBearing += 30.0;
      _moveCamera();
    });
  }

  void _rotateCAmeraRight() {
    setState(() {
      _defaultBearing -= 30.0;
      _moveCamera();
    });
  }

  void _anglePlus() {
    setState(() {
      if (_defaultTilt < 90.0) {
        _defaultTilt += 45.0;
        _moveCamera();
      }
    });
  }

  void _angleMinus() {
    setState(() {
      if (_defaultTilt > 0.0) {
        _defaultTilt -= 45.0;
        _moveCamera();
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _atualZoom += 1.0;
      _moveCamera();
    });
  }

  void _zoomOut() {
    setState(() {
      _atualZoom -= 1.0;
      _moveCamera();
    });
  }

  bool _wideView = false;

  void _visualizacaoAmpla() {
    _wideView = !_wideView;
    if(_wideView){
      _atualZoom = 10.0;
      _moveCamera();
    }else{
      _atualZoom = _defaultZoom;
      _moveCamera();
    }

  }

}
