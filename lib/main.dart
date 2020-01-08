import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController _controller;
  Position position; 
  Widget _child;

  //LIST of pre-fed locations for the events typecasted as SET. I've explained it later

  Set<Marker> _markers;

  @override
  void initState() {
    _child = Center(child: CircularProgressIndicator());
    getCurrentLocation();  
    super.initState();
  }

  void getCurrentLocation() async {

    //waits till the current location is obtained and then opens the map on that location and rebuilds the widget tree
    
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _child = mapWidget();
    });
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),  
      ),
      body: Column(  
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              height: 440,
              child: _child),
          Container(
            height: 200,
            child: ListView(
              children: <Widget>[

                //Expansion tile containing the list of locations. for current implementation only we'll remove this later
                
                ExpansionTile(
                  title: Text(
                    "Where do you want to go?",
                    textAlign: TextAlign.center,
                  ),
                  children: <Widget>[
                    buildListTile("AB5"),
                    buildListTile("Innovation Center"),
                    buildListTile("Food Court"),
                    buildListTile("NLH"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarker() {

    // the LIST of positions have to be used as a SET since 
    // that's the data type GoogleMap widget expects, we change it later to 
    // a list for ease of use. 

    _markers = <Marker>[
      Marker(
          markerId: MarkerId("AB5"),
          position: LatLng(13.352977, 74.793587),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "AB5")),
      Marker(
          markerId: MarkerId("Innovation Center"),
          position: LatLng(13.351587, 74.792669),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Innovation Center")),
      Marker(
          markerId: MarkerId("Food Court"),
          position: LatLng(13.347493, 74.793765),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Food Court"))
    ].toSet();

    return _markers;
  }

  Widget mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: _createMarker(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      initialCameraPosition: CameraPosition(
          zoom: 16.0, target: LatLng(position.latitude, position.longitude)),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }

  ListTile buildListTile(String str) {
    return ListTile(
      title: Text(
        str,
      ),
      onTap: () {
        _goToLocation(str);
      },
    );
  }

  Future<void> _goToLocation(String str) async {
    List<Marker> _markerList = _markers.toList();
    LatLng pos;

    // this is the onTap function for the list of locations. tapping will
    // search throught the list of locations and select the one whose name is
    // same as that of the tile we have tapped on (I'm passing the name of the tile as an argument)

    for (var i in _markerList) {
      if (i.markerId.value == str) {
        pos = i.position;
      }
    }

    //simply animates the camera to the position we have selected

    _controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 16)));
  }
}
