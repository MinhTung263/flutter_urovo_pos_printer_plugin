import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_urovo_pos_printer_plugin/flutter_urovo_pos_printer_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterUrovoPosPrinterPlugin = FlutterUrovoPosPrinterPlugin();
  String status = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterUrovoPosPrinterPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            Center(
              child: Text('Running on: $status\n'),
            ),
            OutlinedButton(
                onPressed: () async {
                  bool print =
                      await _flutterUrovoPosPrinterPlugin.initPrinter() ??
                          false;
                  debugPrint('--------------------Print ready');
                  print
                      ? debugPrint('Print ready')
                      : debugPrint('Print not found');
                  setState(() {
                    status = print ? 'Print ready' : 'Print not found';
                  });
                },
                child: const Text('Print Initialize')),
            OutlinedButton(
                onPressed: () async {
                  bool print =
                      await _flutterUrovoPosPrinterPlugin.printTest() ?? false;
                  debugPrint('--------------------');
                  print
                      ? debugPrint('Print ready')
                      : debugPrint('Print not found');
                  setState(() {
                    status = status = print ? 'Print ready' : 'Print not found';
                  });
                },
                child: const Text('Print')),
            OutlinedButton(
                onPressed: () async {
                  var state = await _flutterUrovoPosPrinterPlugin.getStatus();
                  debugPrint('--------Get Status------------');
                  debugPrint('Print Status=$state');
                  setState(() {
                    status = 'Print Status$status';
                  });
                },
                child: const Text('Get Status')),
            OutlinedButton(
                onPressed: () async {
                  final state = await _flutterUrovoPosPrinterPlugin.setupPage(
                          height: 348, width: -1) ??
                      false;
                  debugPrint('--------Setup page------------');
                  state
                      ? debugPrint('Print Setup page')
                      : debugPrint('Print not found');
                  setState(() {
                    status =
                        status = state ? 'Print Setup page' : 'Print not found';
                  });
                },
                child: const Text('setup page')),
            OutlinedButton(
                onPressed: () async {
                  await _flutterUrovoPosPrinterPlugin.setupPage(
                      height: 348, width: -1);
                  debugPrint('--------drawline------------');
                  _flutterUrovoPosPrinterPlugin.drawLine(
                      x0: 30, y0: 20, x1: 10, y1: 30, lineWidth: 89);
                  String respond = await _flutterUrovoPosPrinterPlugin
                          .printPage(rotate: 0) ??
                      '';
                  setState(() {
                    status = 'draw line ok';
                  });
                },
                child: const Text('Draw Li    ne')),
            OutlinedButton(
                onPressed: () async {
                  bool state =
                      await _flutterUrovoPosPrinterPlugin.dispose() ?? false;
                  debugPrint('-------dispose------------');
                  state
                      ? debugPrint('Print Status')
                      : debugPrint('Print not found');
                  setState(() {
                    status =
                        status = state ? 'Print Status' : 'Print not found';
                  });
                },
                child: const Text('Dispose')),
            OutlinedButton(
                onPressed: () async {
                  // await _flutterUrovoPosPrinterPlugin.forward(100);
                  debugPrint('-------forward------------');
                },
                child: const Text('Forward')),
            OutlinedButton(
                onPressed: () async {
                  await _flutterUrovoPosPrinterPlugin.setupPage(
                      height: 384, width: -1);
                  await _flutterUrovoPosPrinterPlugin.drawText(
                      data: "Hello\nHi",
                      x: 200,
                      y: 1000,
                      fontName: "simsun",
                      fontSize: 24,
                      isBold: true,
                      isItalic: false,
                      rotate: 0);
                  await _flutterUrovoPosPrinterPlugin.printPage(rotate: 0);
                  debugPrint('-------drawText------------');
                  setState(() {
                    status = 'draw text ok';
                  });
                },
                child: const Text('Draw Text')),
            OutlinedButton(
                onPressed: () async {
                  final imageBm = await getImageFile('assets/image/bill.png');
                  final uiImage = await loadImage(imageBm.path);
                  const printerPageWidth = 384;
                  final scaledHeight =
                      (uiImage.height / uiImage.width * printerPageWidth)
                          .round();
                  await _flutterUrovoPosPrinterPlugin.setupPage(
                    width: -1,
                    height: scaledHeight + 140,
                  );
                  await _flutterUrovoPosPrinterPlugin.drawBitmap(
                    image: imageBm.path,
                    xDest: -1,
                    yDest: -1,
                  );

                  await _flutterUrovoPosPrinterPlugin.printPage(rotate: 0);

                  setState(() {
                    status = 'draw bitmap ok';
                  });
                },
                child: const Text('Draw Bitmap  ')),
          ],
        ),
      ),
    );
  }

  Future<File> getImageFile(String path) async {
    final byteData = await rootBundle.load(path);

    final file = await File('${(await getTemporaryDirectory()).path}/$path')
        .create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<Uint8List> setImageFile(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Future<ui.Image> loadImage(String path) async {
    final data = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
