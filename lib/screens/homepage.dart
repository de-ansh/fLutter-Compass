import 'package:compass/screens/neo_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _haspermission = false;

  @override
  void initState() {
    super.initState();
    _fethchPermissionStatus();
  }

  void _fethchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _haspermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (_haspermission) {
          return _buildCompass();
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }

  //Compass widget
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return NeuCircle(
          child: Transform.rotate(
            angle: (direction * (math.pi / 180) * -1),
            child: Image.asset(
              'assests/compass.png',
              color: Colors.white,
              fit: BoxFit.fitHeight,
            ),
          ),
        );
      },
    );
  }

  //permission Widget
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse
                .request()
                .then((value) => {_fethchPermissionStatus()});
          },
          child: Text("Request Permission")),
    );
  }
}
