import 'package:flutter/material.dart';

class Site_bar extends StatefulWidget {
  const Site_bar({super.key});
  @override
  _Site_barState createState() => _Site_barState();
}

class _Site_barState extends State<Site_bar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sidebar Menu Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('John Doe'),
              accountEmail: Text('johndoe@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://example.com/your_profile_picture.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to the home screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Navigate to the profile screen
                Navigator.pop(context);
                // You can add navigation logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to the settings screen
                Navigator.pop(context);
                // You can add navigation logic here
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Add logout logic here
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Home Screen'),
      ),
    );
  }
}
