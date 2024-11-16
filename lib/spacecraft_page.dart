import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voyager_net/chat.dart';

class SpacecraftPage extends StatefulWidget {
  const SpacecraftPage({super.key});

  @override
  SpacecraftPageState createState() => SpacecraftPageState();
}

class SpacecraftPageState extends State<SpacecraftPage> {
  int _currentIndex = 0;
  double _rotationX = 0.0; // Rotation around the X-axis
  double _rotationY = 0.0; // Rotation around the Y-axis
  Offset _spacecraftPosition = const Offset(0.6, 0.2); // Spacecraft position in orbit
  double _spacecraftRotation = 0.0; // Spacecraft rotation
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Simulate position updates (to be replaced with server data)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Update spacecraft position (example: move in orbit)
        double angle = timer.tick * pi / 30; // Orbit step
        _spacecraftPosition = Offset(0.5 + 0.3 * cos(angle), 0.5 + 0.3 * sin(angle));
        // Rotate spacecraft
        _spacecraftRotation += 0.1; // Example rotation increment
      });
    });

    // Placeholder for server integration
    _startServerUpdates();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startServerUpdates() {
    // TODO: Implement server data fetching and update the spacecraft's velocity, rotation, and position
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _rotateSpacecraft(double angleDelta) {
    setState(() {
      _spacecraftRotation += angleDelta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voyager Net'),
      ),
      body: _currentIndex == 0 ? _buildMainControl() : const ChatWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.rocket), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }

  Widget _buildMainControl() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Earth and spacecraft
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _rotationX += details.delta.dy * 0.01;
                _rotationY += details.delta.dx * 0.01;
              });
            },
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateX(_rotationX)
                  ..rotateY(_rotationY),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Earth image
                    Image.network(
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA5L3JtNjUzYmF0Y2gyLWVsZW1lbnQtMTEyYS10cmF2ZWxfMS5wbmc.png',
                      height: 200,
                      width: 200,
                    ),
                    // Spacecraft image
                    Positioned(
                      left: _spacecraftPosition.dx * 200 - 25,
                      top: _spacecraftPosition.dy * 200 - 25,
                      child: Transform.rotate(
                        angle: _spacecraftRotation,
                        child: Image.network(
                          'https://www.citypng.com/public/uploads/preview/cartoon-flight-spaceship-rocket-clipart-735811696949072cgzl3oyowp.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Control panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => print('Thrust Up'),
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () => print('Thrust Down'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => print('Thrust Left'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => print('Thrust Right'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Rotation controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.rotate_left),
                    onPressed: () => _rotateSpacecraft(-0.1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () => _rotateSpacecraft(0.1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
