import 'package:flutter/material.dart';
import 'chat.dart'; // Import the ChatScreen
import 'spacecraft.dart';

void main() {
  runApp(const VoyagerNet());
}

class VoyagerNet extends StatelessWidget {
  const VoyagerNet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoyagerNet',
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final domain = _domainController.text;

    if (username.isNotEmpty && password.isNotEmpty && domain.isNotEmpty) {
      // Navigate to ChatScreen on successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with rounded corners and larger size
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'lib/VoyagerNet.png',
                    height: isDesktop ? 180 : 120, // Larger for desktop
                    width: isDesktop ? 180 : 120, // Maintain aspect ratio
                  ),
                ),
                const SizedBox(height: 40),
                // Username field
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  icon: Icons.person,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 20),
                // Password field
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 20),
                // Domain field
                _buildTextField(
                  controller: _domainController,
                  labelText: 'Domain',
                  icon: Icons.web,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 40),
                // Login button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.amber.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    required bool isDesktop,
  }) {
    return SizedBox(
      width: isDesktop ? MediaQuery.of(context).size.width * 0.4 : double.infinity,
      height: 40,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black54,
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.amber.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.amber),
          ),
        ),
      ),
    );
  }
}
