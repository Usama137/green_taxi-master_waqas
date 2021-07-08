import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_taxi/model/card_model.dart';
import 'package:green_taxi/model/place_model.dart';
import 'package:green_taxi/model/ride_option_model.dart';
import 'package:green_taxi/ui/pages/qr_scanner_page.dart';
import 'package:green_taxi/ui/widgets/drawer_widget.dart';
import 'package:green_taxi/utils/constants.dart';
import 'package:green_taxi/utils/styles.dart';

import 'package:green_taxi/provider/google_map_service.dart';
import 'package:uuid/uuid.dart';

import 'taxi_movement_page.dart';

class BookTaxiPage extends StatefulWidget {

  final databaseReference = FirebaseDatabase.instance.reference();
  static final routeName = "book-taxi-page";

  @override
  _BookTaxiPageState createState() => _BookTaxiPageState();
}

class _BookTaxiPageState extends State<BookTaxiPage> {
  LatLng myLocation;
  Set<Marker> _markers = {};
  String _mapStyle;
  BitmapDescriptor _taxilocation;
  BitmapDescriptor _mylocation;
  BitmapDescriptor _mydestination;
  Completer<GoogleMapController> _controller = Completer();
  bool isMapCreated = false;
  final Key _mapKey = UniqueKey();
  int _selectedIndex = -1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  var uuid = Uuid();
  var sessionToken;
  var googleMapServices;
  PlaceDetail _fromPlaceDetail;
  PlaceDetail _toPlaceDetail;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  bool _hasGottenCordinates = false;
  LatLngBounds bound;

  List<UserCardModel> _cards = [
    UserCardModel(
        id: "1",
        imageUrl: 'assets/images/img_visa_logo.png',
        cardNumber: "**** **** **** 5687"),
    UserCardModel(
        id: "2",
        imageUrl: 'assets/images/img_visa_logo.png',
        cardNumber: "**** **** **** 9987"),
    UserCardModel(
        id: "3",
        imageUrl: 'assets/images/img_visa_logo.png',
        cardNumber: "**** **** **** 7879")
  ];

  List<RideOptionModel> ridesOptions = [
    RideOptionModel(
        id: "1",
        price: 9.90,
        estimatedTime: "60 KM/H",
        rideType: "098798",
        index: 0,
        imageUrl: "assets/images/bike01.png"),
    RideOptionModel(
        id: "2",
        price: 10.90,
        index: 1,
        estimatedTime: "80 KM/H",
        rideType: "987653",
        imageUrl: "assets/images/bike01.png"),
    RideOptionModel(
        id: "3",
        price: 49.90,
        index: 2,
        estimatedTime: "100 KM/H",
        rideType: "672898",
        imageUrl: "assets/images/bike01.png"),
    RideOptionModel(
        id: "3",
        price: 49.90,
        index: 2,
        estimatedTime: "100 KM/H",
        rideType: "672812",
        imageUrl: "assets/images/bike01.png")
  ];

  UserCardModel _selectedalvalue;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/taxi.png')
        .then((onValue) {
      _taxilocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/mylocation.png')
        .then((onValue) {
      _mylocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/mydestination.png')
        .then((onValue) {
      _mydestination = onValue;
    });

    rootBundle.loadString('assets/images/map_style.txt').then((string) {
      _mapStyle = string;
    });
    super.initState();

    _selectedalvalue = _cards[0];

    myLocation = LatLng(27.725765, 68.819862);
    _markers.add(Marker(
        markerId: MarkerId("Block 01"),
        position: LatLng(27.725461, 68.820009),
        icon: _mylocation,
        infoWindow: InfoWindow(
          title: "Block 01",
        ),
        onTap: () {}));


    _markers.add(Marker(
        markerId: MarkerId("Block 02"),
        position: LatLng(27.726126, 68.819811),
        icon: _mylocation,
        infoWindow: InfoWindow(
          title: "Block 02",
        ),
        onTap: () {
          _buildToFromDestination();
        }));


    _markers.add(Marker(
        markerId: MarkerId("Block 03"),
        position: LatLng(27.725475, 68.818948),
        icon: _mylocation,
        infoWindow: InfoWindow(
          title: "Block 03",
          onTap: (){

          }
        ),
        onTap: () {

        }));


    _markers.add(Marker(
        markerId: MarkerId("Cafe"),
        position: LatLng(27.725746, 68.819548),
        icon: _mylocation,
        infoWindow: InfoWindow(
          title: "Cafe",
        ),
        onTap: () {
          //_buildSelectRideWidget();




        }));
  }

  Future<void> getMyLocation() async {
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
   myLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      //myLocation = LatLng(6.31, 5.2139453);
      myLocation=LatLng(position.latitude,position.longitude);
    });

    print(position);
  }

  setPolylines() async {
    polylineCoordinates.clear();
    _polylines.clear();
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        Constatnts.API_KEY,
        _fromPlaceDetail.lat,
        _fromPlaceDetail.lng,
        _toPlaceDetail.lat,
        _toPlaceDetail.lng);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: Colors.blue,
          width: 4,
          points: polylineCoordinates);
      _polylines.add(polyline);
      _hasGottenCordinates = true;
    });
  }

  void _moveCamera(
      PlaceDetail _fromplaceDetail, PlaceDetail _toPlaceDetail) async {
    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }
    if (_toLocationController.text != null && _toPlaceDetail != null) {
      getLatLngBounds(LatLng(_fromplaceDetail.lat, _fromplaceDetail.lng),
          LatLng(_toPlaceDetail.lat, _toPlaceDetail.lng));
      GoogleMapController controller = await _controller.future;
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      controller.animateCamera(u2).then((void v) {
        check(u2, controller);
      });
      // controller.animateCamera(CameraUpdate.newLatLng(
      //   LatLng(_toPlaceDetail.lat, _toPlaceDetail.lng),
      // ));
    }

    setState(() {
      if (_fromLocationController.text != null && _fromplaceDetail != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(_fromplaceDetail.placeId),
            position: LatLng(_fromplaceDetail.lat, _fromplaceDetail.lng),
            icon: _mylocation,
            infoWindow: InfoWindow(
              title: "pick up",
              snippet: _fromplaceDetail.formattedAddress,
            ),
          ),
        );
      }

      if (_toLocationController.text != null && _toPlaceDetail != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(_toPlaceDetail.placeId),
            position: LatLng(_toPlaceDetail.lat, _toPlaceDetail.lng),
            icon: _mydestination,
            infoWindow: InfoWindow(
              title: "destination",
              snippet: _toPlaceDetail.formattedAddress,
            ),
          ),
        );
      }
    });

    if (_toLocationController.text != null &&
        _toPlaceDetail != null &&
        _fromLocationController.text != null &&
        _fromplaceDetail != null) {
      await setPolylines();
    }
  }

  void getLatLngBounds(LatLng from, LatLng to) {
    if (from.latitude > to.latitude && from.longitude > to.longitude) {
      bound = LatLngBounds(southwest: to, northeast: from);
    } else if (from.longitude > to.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(from.latitude, to.longitude),
          northeast: LatLng(to.latitude, from.longitude));
    } else if (from.latitude > to.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(to.latitude, from.longitude),
          northeast: LatLng(from.latitude, to.longitude));
    } else {
      bound = LatLngBounds(southwest: from, northeast: to);
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void _clearCordinate() {
    setState(() {
      _fromLocationController.clear();
      _toLocationController.clear();
      _hasGottenCordinates = false;
      _polylines = {};
      _markers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          Container(
              margin: const EdgeInsets.only(top: 0),
              height: MediaQuery.of(context).size.height * 0.6,
              child: myLocation == null
                  ? Center(
                      child: Text("Loading Map"),
                    )
                  : GoogleMap(
                      key: _mapKey,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      markers: _markers,
                      polylines: _polylines,
                      initialCameraPosition:
                          CameraPosition(target: myLocation, zoom: 18),
                      onMapCreated: (GoogleMapController controller) {
                        controller.setMapStyle(_mapStyle);
                        _controller.complete(controller);
                      },
                    )),
          Positioned(top: 65, left: 5, right: 5, child: _buildHelloWidget()),


           (_hasGottenCordinates)
               ? _buildSelectRideWidget()
               :_buildToFromDestination() ,


        // _buildSelectRideWidget(),

          Positioned(
            top: 25.0,
            left: 5.0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.amberAccent,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  }),
            ),
          ),
          Positioned(
            top: 25.0,
            right: 5.0,
            child: _hasGottenCordinates
                ? GestureDetector(
                    onTap: () {
                      _clearCordinate();
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.amber,
                      size: 40,
                    ),
                  )
                : Text(""),
          )
        ],
      ),
    );
  }

  Widget _buildToFromDestination() {
    return Positioned(
        bottom: 5,
        left: 5,
        right: 5,
        child: Card(
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              children: <Widget>[
                TypeAheadField(
                  direction: AxisDirection.up,
                  debounceDuration: Duration(milliseconds: 500),
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _fromLocationController,
                    //  autofocus: true,
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                        icon: new Icon(
                          FontAwesomeIcons.bicycle,
                          color: Colors.green,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 15,
                            ),
                            onPressed: () {
                              _fromLocationController.clear();
                            }),
                        labelText: "From"),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (sessionToken == null) {
                      sessionToken = uuid.v4();
                    }
                    googleMapServices =
                        GoogleMapServices(sessionToken: sessionToken);
                    return await googleMapServices.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggetion) {
                    return ListTile(
                      title: Text(
                        suggetion.description,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggetion) async {
                    _fromLocationController.text = suggetion.description;
                    _fromPlaceDetail = await googleMapServices.getPlaceDetail(
                      suggetion.placeId,
                      sessionToken,
                    );

                    //    _moveCamera(_fromPlaceDetail, _toPlaceDetail);
                    sessionToken = null;
                  },
                ),
                TypeAheadField(
                  direction: AxisDirection.up,
                  debounceDuration: Duration(milliseconds: 500),
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _toLocationController,
                    //  autofocus: true,
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                        icon: new Icon(
                          FontAwesomeIcons.dotCircle,
                          color: Colors.red,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 15,
                            ),
                            onPressed: () {
                              _toLocationController.clear();
                            }),
                        labelText: "To"),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (sessionToken == null) {
                      sessionToken = uuid.v4();
                    }
                    googleMapServices =
                        GoogleMapServices(sessionToken: sessionToken);
                    return await googleMapServices.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggetion) {
                    return ListTile(
                      title: Text(
                        suggetion.description,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggetion) async {
                    _toLocationController.text = suggetion.description;
                    _toPlaceDetail = await googleMapServices.getPlaceDetail(
                      suggetion.placeId,
                      sessionToken,
                    );
                    _moveCamera(_fromPlaceDetail, _toPlaceDetail);
                    sessionToken = null;
                  },
                ),
                SizedBox(
                  height: 45,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHelloWidget() {
    return _hasGottenCordinates
        ? Text("")
        : Card(
            child: Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.user,
                  color: Constatnts.primaryColor,
                  size: 40,
                ),
                title: Text(
                  "Hello Waqas",
                  style: CustomStyles.smallTextStyle,
                ),
                subtitle: Text(
                  "Where are you Going to ?",
                  style: CustomStyles.normalTextStyle,
                ),
              ),
            ),
          );
  }

  Widget _buildSelectRideWidget() {
    return Positioned(
      bottom: 5,
      left: 5,
      right: 5,
      child: Card(
        child: Container(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Select Ride",
                style: CustomStyles.normalTextStyle,
              ),
              Container(
                height: 140,
                child: ListView.builder(
                    itemCount: ridesOptions.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.all(15.0),
                          elevation: 10,
                          color: _selectedIndex == ridesOptions[index].index
                              ? Constatnts.primaryColor
                              : Colors.white,
                          child: Container(
                            child: Container(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          ridesOptions[index].rideType,
                                          style: _selectedIndex ==
                                                  ridesOptions[index].index
                                              ? CustomStyles.cardBoldTextStyle
                                              : CustomStyles
                                                  .cardBoldDarkTextStyle,
                                        ),
                                        Text(
                                          "N ${ridesOptions[index].price.toString()}",
                                          style: _selectedIndex ==
                                                  ridesOptions[index].index
                                              ? CustomStyles.cardNormalTextStyle
                                              : CustomStyles
                                                  .cardNormalDarkTextStyle,
                                        ),
                                        Text(
                                          ridesOptions[index].estimatedTime,
                                          style: _selectedIndex ==
                                                  ridesOptions[index].index
                                              ? CustomStyles.cardNormalTextStyle
                                              : CustomStyles
                                                  .cardNormalDarkTextStyle,
                                        )
                                      ],
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                            ridesOptions[index].imageUrl))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 50.0,
                    child: DropdownButton<UserCardModel>(
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.amberAccent,
                      ),
                      items: _cards.map((UserCardModel value) {
                        return new DropdownMenuItem<UserCardModel>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Image.asset(
                                  value.imageUrl,
                                  height: 16,
                                ),
                                Text(
                                  value.cardNumber,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ));
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedalvalue = value;
                        });
                      },
                      underline: SizedBox(),
                      isExpanded: true,
                      elevation: 0,
                      value: _selectedalvalue,

                      // onSaved: (value) {

                      // },
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constatnts.primaryColor,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, QRViewExample.routeName, (route) => true);
                       return TaxiMovementPage(
                        fromPlaceDetail: _fromPlaceDetail,
                        toPlaceDetail: _toPlaceDetail,
                        polylines: _polylines,
                        polylineCoordinates: polylineCoordinates,
                      );


                    },
                    child: Text(
                      "Confirm",
                      style: CustomStyles.cardBoldTextStyle,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


// Navigator.of(context)
// .push(new MaterialPageRoute(builder: (context) {
// return TaxiMovementPage(
// fromPlaceDetail: _fromPlaceDetail,
// toPlaceDetail: _toPlaceDetail,
// polylines: _polylines,
// polylineCoordinates: polylineCoordinates,
// );
// }