import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:freelanceapp/bill.dart';
import 'package:freelanceapp/blue_print.dart';
import 'package:freelanceapp/store.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler;

FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String tempVar = '';
  List<ScanResult>? scanResult;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Bill> bills = [
      Bill(name: "Black coffee", amount: 1.0, price: 200, total: 200),
      Bill(name: "Bread", amount: 1.0, price: 250, total: 250),
      Bill(name: "Onion", amount: 3.2, price: 200, total: 640),
      Bill(name: "Coke", amount: 1.0, price: 200, total: 200),
    ];
    Store store = Store(
      store_name: "Halo Coffee Shop",
      store_address: "1st Nguyen Thanh Chu street, Ho Chi Minh city",
      store_phone_number: "+8499999999",
    );
    final String logoLink =
        'https://i.pinimg.com/originals/09/26/3e/09263e869d4d8feba0e495b5ad591319.jpg';

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            const Text(
              'Press the button to print the bill',
            ),
            ElevatedButton(
              child: Text("Search Devices"),
              onPressed: () {
                findDevices();
              },
            ),
            scanResult == null
                ? Center(
                    child: Column(
                      children: [
                        Text('No device avaialble!'),
                        Text(tempVar),
                      ],
                    ),
                  )
                : scanResult!.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Text('No device avaialble!'),
                            Text(tempVar),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Text(),
                          Center(child: Text('Select device')),
                          Container(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    scanResult![index].device.name,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  trailing: MaterialButton(
                                    onPressed: () {
                                      printWithDevice(
                                          scanResult![index].device);
                                    },
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    child: Text('Print'),
                                  ),
                                  subtitle:
                                      Text(scanResult![index].device.id.id),
                                  // onTap: () {
                                  //   printWithDevice(scanResult![index].device);
                                  // },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: scanResult?.length ?? 0,
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> findDevices() async {
    if (!await flutterBlue.isOn) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Enable bluetooth to continue'),
              ),
              // child: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: const [
              //     Padding(
              //       padding: EdgeInsets.all(20),
              //       child: Text('Enable bluetooth to continue'),
              //     ),
              //   ],
              // ),
            );
          });

      return;
    }

    var statusL = await permissionHandler.Permission.location.request();

    if (statusL.isGranted) {
      var statusS = await permissionHandler.Permission.bluetoothScan.request();

      if (statusS.isGranted) {
        var statusC =
            await permissionHandler.Permission.bluetoothConnect.request();

        if (statusC.isGranted) {
          // showBluetoothListDialog();

          flutterBlue.startScan(timeout: const Duration(seconds: 4));

          flutterBlue.scanResults.listen((results) {
            setState(() {
              scanResult = results;
            });
          });
          flutterBlue.stopScan();

          await Future.delayed(Duration(seconds: 10));

          tempVar = 'aaaaa';

          setState(() {});

          print('hi000000000000');
        }
      }
    }
  }

  void printWithDevice(BluetoothDevice device) async {
    await device.connect();

    final gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
    final printer = BluePrint();
    printer.add(gen.qrcode('https://google.com'));
    printer.add(gen.text('Hello'));
    printer.add(gen.text('World', styles: const PosStyles(bold: true)));
    printer.add(gen.feed(1));
    await printer.printData(device);
    device.disconnect();
  }

  // showBluetoothListDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return AlertDialog(
  //             content: SizedBox(
  //               height: 300,
  //               child: Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: scanResult!.isEmpty
  //                     ? Center(
  //                         child: Column(
  //                           children: [
  //                             Text('No device avaialble!'),
  //                             Text(tempVar),
  //                           ],
  //                         ),
  //                       )
  //                     : Column(
  //                         children: [
  //                           Center(child: Text('Select device')),
  //                           ListView.separated(
  //                             itemBuilder: (context, index) {
  //                               return ListTile(
  //                                 title: Text(
  //                                   scanResult![index].device.name,
  //                                   style: const TextStyle(color: Colors.black),
  //                                 ),
  //                                 subtitle:
  //                                     Text(scanResult![index].device.id.id),
  //                                 onTap: () {
  //                                   printWithDevice(scanResult![index].device);
  //                                 },
  //                               );
  //                             },
  //                             separatorBuilder: (context, index) =>
  //                                 const Divider(),
  //                             itemCount: scanResult?.length ?? 0,
  //                           ),
  //                         ],
  //                       ),
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }
}
