import 'package:flutter/material.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/screens/profile_screen.dart';
import 'package:project_live_streaming/screens/feed_screen.dart';
import 'package:project_live_streaming/screens/go_live_screen.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  onPageChange(int page){
    setState((){
      _page = page;
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    List<Widget> pages = [
      const FeedScreen(),
      const GoLiveScreen(),
      ProfileScreen(broadcasterUid: userProvider.user.uid, isBroadcaster: false,),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: buttonColor,
        unselectedItemColor: primaryColor,
        backgroundColor: backgroundColor,
        onTap: onPageChange,
        currentIndex: _page,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
            label: 'Following'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_rounded),
              label: 'Go Live'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'
          ),
        ],
      ),
      body: pages[_page],
    );
  }
}
