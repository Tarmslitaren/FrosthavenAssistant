import 'package:flutter/material.dart';

Drawer createMainMenu(BuildContext context) {
  return Drawer(
// Add a ListView to the drawer. This ensures the user can scroll
// through the options in the drawer if there isn't enough vertical
// space to fit everything.
    child: ListView(
// Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Main Menu'),
        ),
        ListTile(
          title: const Text('Undo'),
          onTap: () {
// Update the state of the app
// ...
// Then close the drawer
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Redo'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(

        ),
        ListTile(
          title: const Text('Set Scenario'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Add Section'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(

        ),
        ListTile(

          title: const Text('Add Characters'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Remove Characters'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(

        ),
        ListTile(
          title: const Text('Add Monsters'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Remove Monsters'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(

        ),
        ListTile(
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Documentation'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );

}