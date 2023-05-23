import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddProvider with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;

  GoogleMapController _mapController;


  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;

  GoogleMapController get mapController => _mapController;


  AddProvider() {
    _getUserLocation();
    _loadingInitialPosition();
  }
// ! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _initialPosition = LatLng(position.latitude, position.longitude);
    print("the latitude is: ${position.longitude} and th longitude is: ${position.longitude} ");
    print("initial position is : ${_initialPosition.toString()}");

    notifyListeners();
  }



  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  LOADING INITIAL POSITION
  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(_initialPosition == null){
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }
}