import 'package:drink_a_bot/MainPage.dart';
import 'package:drink_a_bot/helpers/constants.dart';
import 'package:flutter/material.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

class LandingPage extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  //var firstColor = Color(0xffdecdc3), secondColor = Color(0xffea5455);
  //var firstColor = Color(0xFF07689f),secondColor = Color(0xffa2d5f2);
  var firstColor = Color(0xFFeb8f8f), secondColor = Color(0xFFec0101);
  var code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            color:  Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50.0, left: 10.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Drink-a-Bot',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //fontFamily: 'Montserrat',
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 50.0,
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Smart Movable Dispenser',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //fontFamily: 'Montserrat',
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
            
                              fontSize: 25.0,
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                                height: 300.0,
                                //width: 200.0,
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: AssetImage('assets/img1.jpeg'),
                                    //ExactAssetImage('assets/img1.jpeg'),
                                    //fit: BoxFit.fitHeight,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 25.0),
                      color: redShade,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPage()),
                          );
                        },
                        child: ListTile(
                          title: Center(
                            child: Text(
                              "Connect Device",
                              style: TextStyle(
                                //fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
