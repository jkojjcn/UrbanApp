import 'package:jcn_delivery/src/models/taxi/location.dart';
import 'package:location/location.dart' as lck;
import 'dart:async';

class LocationService {
  UserLocation? _currentLocation;

  var location = lck.Location();
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    // Request permission to use location
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == lck.PermissionStatus.granted) {
        location.enableBackgroundMode(enable: true);
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.changeSettings(interval: 5000);
        location.onLocationChanged.listen((locationData) {
          // ignore: unnecessary_null_comparison
          if (locationData != null) {
            _locationController.add(UserLocation(
                latitude: locationData.latitude!,
                longitude: locationData.longitude!,
                speed: locationData.speed!,
                heading: locationData.heading!));
          }
        });
      }
    });
  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
          latitude: userLocation.latitude!,
          longitude: userLocation.longitude!,
          speed: userLocation.speed!,
          heading: userLocation.heading!);
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation!;
  }
}
