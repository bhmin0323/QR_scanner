import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class QRpage extends StatefulWidget {
  @override
  _QRpageState createState() => _QRpageState();
}

class _QRpageState extends State<QRpage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission(); // 카메라 권한 요청 함수 호출
  }

  void _requestCameraPermission() async {
    await Permission.camera.request(); // 카메라 권한 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 스캔'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('QR 코드를 스캔하세요'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final String qrText = scanData.code!;
      await controller.pauseCamera();

      // QR 코드 데이터를 표시하는 대화상자 표시
      showDialog(
        context: context,
        barrierDismissible: true, // 화면의 다른 부분을 누르면 대화상자 닫기
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('QR 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Uri.tryParse(qrText)?.isAbsolute ?? false)
                  InkWell(
                    child: Text(
                      qrText,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      // 링크라면 브라우저로 이동
                      launchUrl(Uri.parse(qrText));
                    },
                  )
                else
                  Text(qrText),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await controller.resumeCamera();
                },
                child: Text('닫기'),
              ),
            ],
          );
        },
      );
    });
  }
}

void main() => runApp(MaterialApp(
      home: QRpage(),
    ));
