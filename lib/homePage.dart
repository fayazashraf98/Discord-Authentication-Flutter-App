import 'package:discordauth/discord_integration.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;

  // This function authenticates with Discord and saves the user data.
  Future<void> _handleAuthentication() async {
    try {
      final data = await authenticate();
      if (data != null) {
        setState(() {
          userData = data;
        });
      }
      print('User Data: $data');
    } catch (e) {
      print('Authentication error: $e');
    }
  }

  // This function logs the user out by clearing the stored user data.
  void _handleLogout() {
    setState(() {
      userData = null;
    });
    print('User logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discord Authentication'),
        actions: [
          if (userData != null)
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: userData == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Click the button below to log in with Discord.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleAuthentication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF7289DA), // Discord blue
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Log in with Discord'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Logged in as: ${userData!['username']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (userData!['avatar'] != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://cdn.discordapp.com/avatars/${userData!['id']}/${userData!['avatar']}.png',
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text('ID: ${userData!['id']}'),
                      Text('Global Name: ${userData!['global_name'] ?? 'N/A'}'),
                      Text('Locale: ${userData!['locale']}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
