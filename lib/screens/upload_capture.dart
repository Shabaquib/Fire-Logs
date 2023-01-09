import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  //connectivity related variables
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  ValueNotifier<bool> statusNotifier = ValueNotifier(false);

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('https://example.com/');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log("Couldn't check connectivity status $e");
      return;
    }
    if (!mounted) {
      return Future.value(null);
    } else {
      return _updateConnectionStatus(result);
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    connectionStatus = result;
    connectionStatusUpdate(connectionStatus);
  }

  connectionStatusUpdate(arg) {
    if (arg == ConnectivityResult.mobile || arg == ConnectivityResult.wifi) {
      statusNotifier.value = false;
    } else {
      statusNotifier.value = true;
    }
  }

  Reference rootStorageReference = FirebaseStorage.instance.ref();
  final ImagePicker _pickerInstance = ImagePicker();
  String systemPathAddress = "";
  late File imageCaptured;
  ValueNotifier<String?> imageFileAddress = ValueNotifier<String?>("");
  TextEditingController nameController = TextEditingController();
  ValueNotifier<String> addressNotifier = ValueNotifier<String>("");
  ValueNotifier<bool> stackVisible = ValueNotifier<bool>(false);

  Future<File?> getLostData() async {
    final LostDataResponse response = await _pickerInstance.retrieveLostData();
    // ignore: unnecessary_null_comparison
    if (response == null && response.isEmpty) {
      return null;
    } else if (response.file != null) {
      log("retrieving lost data!");
      imageCaptured = File((response.file)!.path);
      imageFileAddress.value = (response.file)!.path;
      return imageCaptured;
    }
  }

  Future<void> clicker() async {
    final XFile? photo = await _pickerInstance.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    imageFileAddress.value = (photo != null) ? photo.path : "";
  }

  uploader(File arg) async {
    Reference dirStorageReference = rootStorageReference.child("monoLogs");
    Reference ref = dirStorageReference.child("${nameController.text}.jpg");

    try {
      await ref.putFile(arg);
      String url = await ref.getDownloadURL();
    } on FirebaseException {
      Fluttertoast.showToast(
        msg: "An error occured!",
        textColor: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.black
            : Colors.white,
        backgroundColor: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Camera"),
              centerTitle: true,
            ),
            FutureBuilder<File?>(
                future: getLostData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                            ),
                            Container(
                              width: screenWidth * 0.8,
                              height: screenHeight * 0.6,
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0)),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(5.0),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                                valueListenable: statusNotifier,
                                builder: (a, b, c) {
                                  return ElevatedButton.icon(
                                      onPressed: () async {
                                        stackVisible.value = true;
                                        uploader(snapshot.data!);
                                      },
                                      icon: const Icon(
                                          Icons.file_upload_outlined),
                                      label: const Text('upload'));
                                })
                          ]);
                    } else {
                      return ValueListenableBuilder<String?>(
                          valueListenable: imageFileAddress,
                          builder: (a, b, c) {
                            if (b != null && b.isNotEmpty) {
                              return SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                        child: TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white))),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        width: screenWidth * 0.8,
                                        height: screenHeight * 0.6,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.5),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(5.0),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          child: Image.file(
                                            File(b),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      ValueListenableBuilder<bool>(
                                          valueListenable: statusNotifier,
                                          builder: (aa, bb, cc) {
                                            return ElevatedButton.icon(
                                              onPressed: bb
                                                  ? null
                                                  : () {
                                                      uploader(File(b));
                                                    },
                                              onLongPress: bb
                                                  ? null
                                                  : () {
                                                      uploader(File(b));
                                                    },
                                              icon: const Icon(
                                                Icons.file_upload_outlined,
                                              ),
                                              label: const Text('upload'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: (bb)
                                                    ? Colors.lime.shade600
                                                    : Colors.lime,
                                              ),
                                            );
                                          }),
                                    ]),
                              );
                            } else {
                              return Center(
                                child: Visibility(
                                    visible: true,
                                    child: Container(
                                      width: screenWidth * 0.8,
                                      height: screenHeight * 0.6,
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.5),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                      child: Container(
                                          margin: const EdgeInsets.all(5.0),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          child: IconButton(
                                              onPressed: clicker,
                                              icon: const Icon(Icons.camera))),
                                    )),
                              );
                            }
                          });
                    }
                  } else {
                    return Center(
                      child: spinkit.SpinKitChasingDots(
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    connectivitySubscription.cancel();
    super.dispose();
  }
}
