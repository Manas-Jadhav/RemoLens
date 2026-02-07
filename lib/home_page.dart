import 'package:flutter/material.dart';
import 'package:remote_finder_app/add_remote.dart';
import 'package:remote_finder_app/all_remotes.dart';
import 'package:remote_finder_app/find_remote.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Finder'),
        leading: Icon(Icons.star_outline),
        titleTextStyle: TextStyle(fontSize: 25),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed:()=>{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const Add_Remote_Page())
                )
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                side: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              child: Text(
                "Add Remote",
                style: TextStyle(fontSize: 26, color: Colors.blueGrey[900]),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> const FindRemotePage())
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                side: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              child: Text(
                "Find Remote",
                style: TextStyle(fontSize: 26, color: Colors.blueGrey[900]),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed:()=>{
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> const AllRemotesPage())
                )
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                side: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              child: Text(
                "All Remotes",
                style: TextStyle(fontSize: 26, color: Colors.blueGrey[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
