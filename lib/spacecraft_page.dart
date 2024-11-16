import 'dart:async';
import 'package:flutter/material.dart';

import 'package:voyager_net/chat.dart';
import 'package:voyager_net/navigation_server.dart';
import 'package:voyager_net/spacecraft.dart';

class SpacecraftPage extends StatefulWidget {
  const SpacecraftPage({super.key});

  @override
  SpacecraftPageState createState() => SpacecraftPageState();
}

class SpacecraftPageState extends State<SpacecraftPage> {
  Spacecraft spacecraft = Spacecraft(
    Offset(0,0),
    0,
    0,
  );
  int thrustPercent = 0;
  int _currentIndex = 0;
  late Timer _timer;

  void fetchAndUpdate() async {
    try {
      final fetchedData = await Server.fetchUpdate();
      setState(() {
        spacecraft = fetchedData;
      });
    }
    catch (e) {
      print("Error fetching update: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch updates every 100ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      fetchAndUpdate();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Earth Image
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 100,
                top: (MediaQuery.of(context).size.height / 2) - 100,
                child: Image.asset(
                    'lib/earth.png',
                    height: 200,
                    width: 200,
                  ),
              ),
              // Spacecraft image
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 25 + spacecraft.coordinates.dx,
                top: (MediaQuery.of(context).size.height / 2) - 25 + spacecraft.coordinates.dy,
                child: Transform.rotate(
                  angle: 3.141519/180 * spacecraft.rotation,
                  child: Image.asset(
                    'lib/rocket.png',
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Control panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Rotation controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.rotate_left),
                    onPressed: () => Server.setRotation(-5), // Rotate left
                  ),
                  // Thrust control as a slider between the rotate buttons
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: thrustPercent.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '$thrustPercent%',
                      onChanged: (double value) {
                        setState(() {
                          thrustPercent = value.toInt();
                        });
                        Server.setThrust(thrustPercent); // Update thrust when slider is moved
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () => Server.setRotation(5), // Rotate right
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
