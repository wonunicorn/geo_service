import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _longitude = TextEditingController();
  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _z = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  String? url;
  static final validFormat = RegExp(r'^(\+|-)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$');
  static final integerRegExp = RegExp(r'^[0-9]*$');

  var x, y;

  num longitudeToX(double longitude, double zoom){
    var result = (longitude + 180)/360* pow(2, zoom);
    return result.floor();
  }

  num latitudeToY(double latitude, double zoom){
    var result = (1- log(tan(latitude * pi/180) + 1/cos(latitude*pi/180))/pi)/2 * pow(2,zoom);
    return result.floor();
  }

  @override
  void dispose() {
    _longitude.dispose();
    _latitude.dispose();
    _z.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WebView.platform = WebWebViewPlatform();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.blue),
                          hintText: "longitude"
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Заполните поле';
                        }else if(!validFormat.hasMatch(value)){
                          return 'Введите корректное значение';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.blue),
                          hintText: "latitude"
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Заполните поле';
                        }else if(!validFormat.hasMatch(value)){
                          return 'Введите корректное значение';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Expanded(
                    child: TextFormField(
                      controller: _z,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.blue),
                          hintText: "z"
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Заполните поле';
                        }
                        else if(!integerRegExp.hasMatch(value)){
                          return 'Введите корректное значение';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15,),
                  ElevatedButton(
                    onPressed: () async{
                      if(_formKey.currentState!.validate()){

                        setState(() {
                          x = longitudeToX(double.parse(_longitude.text.trim()), double.parse(_z.text.trim()));
                          y = latitudeToY(double.parse(_latitude.text.trim()), double.parse(_z.text.trim()));
                        });

                        //var newUrl = "https://yandex.ru/maps/geo/moskva/53166393/?l=carparks&x=$x&y=$y&z=${_z.text.trim()}";

                        var myUrl = "http://yandex.ru/maps/geo/moskva/53166393/?l=carparks&ll=${_longitude.text.trim()}%2C${_latitude.text.trim()}&z=${_z.text.trim()}";
                        setState(() {
                          url = myUrl;
                        });
                        await launchUrl(Uri.parse(myUrl));
                      }
                    },
                    child: const Text("Search"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15,),
            Text("X is ${x.toString()}"),
            const SizedBox(height: 15,),
            Text("Y is ${y.toString()}"),
            const SizedBox(height: 20,),
            Expanded(
              child: url != null ? WebView(
                initialUrl: url,
                onWebViewCreated: (WebViewController controller) {
                  _controller.complete(controller);
                },
              ) : Container(),
            ),
          ],
        ),

      ),
    );
  }
}




