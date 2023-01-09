import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_models/authservice.dart';
import '../data_models/global_data.dart';
import '../data_models/user.dart';
import 'edit_note.dart';
import 'notes_list.dart';
import 'trash_page.dart';
import 'upload_capture.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.userID}) : super(key: key);
  final CustomUser userID;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthService auth = AuthService();
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;

  late AnimationController controller;

  void _launchmyURL(arg) async {
    if (!await launchUrl(arg)) {
      throw 'Could not launch $arg';
    }
  }

  void _revokeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text("About the Dev")),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 30.0,
                ),
                const CircleAvatar(
                  foregroundImage: AssetImage("Assets/ImageAssets/Logo.jpg"),
                ),
                const SizedBox(
                  width: 30.0,
                ),
                const Text(
                  "As a Dev once said:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  width: 30.0,
                ),
                Container(
                  margin: const EdgeInsets.all(15.0),
                  child: const Text(
                    "\"The development is still in beta\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                const Text(
                  "Hi, I am Mohammad Ahsan Aquib Raushan. This Application is one of my personal projects that uses Firebase Authentication & Firebase Firestore to store and sync logs created here in real time. Have a suggestion! or something that you want to be added? Or maybe just want to explore my skills? Check me out on any of the platforms given below!",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _launchmyURL("https://www.github.com/Shabaquib");
                      },
                      child: SvgPicture.asset("Assets/SvgAssets/github.svg"),
                    ),
                    GestureDetector(
                        onTap: () {
                          _launchmyURL(
                              "https://www.linkedin.com/in/ahsan-aquib-raushan-b5b59118a/");
                        },
                        child:
                            SvgPicture.asset("Assets/SvgAssets/linkedin.svg")),
                    GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(const ClipboardData(
                              text: "abrokedesigner@yahoo.com"));
                        },
                        child: const Icon(Icons.email_outlined)),
                    GestureDetector(
                      onTap: () {
                        _launchmyURL("https://shabaquib.github.io/");
                      },
                      child: Transform.rotate(
                          angle: -45 * math.pi / 180,
                          child: const Icon(Icons.link_rounded)),
                    ),
                    GestureDetector(
                        onTap: () {
                          _launchmyURL("https://www.behance.net/ahsanaquib");
                        },
                        child:
                            SvgPicture.asset("Assets/SvgAssets/Behance.svg")),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ElevatedButton.icon(
                    onPressed: () {
                      auth.signOut();
                      Navigator.pop(context);
                      showToast(context, "Logged Out");
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout')),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Made with ❤ by Me & Mono",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> anyKey = GlobalKey();
    return Scaffold(
      key: anyKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _revokeDialog(context);
          },
          icon: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundImage: AssetImage(
                "Assets/ImageAssets/avataaars(${math.Random().nextInt(10)}).png"),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Mono-Log",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await Future.delayed(
                    const Duration(seconds: 1, milliseconds: 500));
                showToast(context, "Synced");
                setState(() {});
              },
              icon: const Icon(Icons.cloud_sync_rounded)),
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TrashPage(
                        userId: widget.userID.uid,
                      ))),
              icon: const Icon(Icons.delete_rounded))
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: (Theme.of(context).brightness == Brightness.dark)
          ? const Color(0xFF252422)
          : const Color(0xFFF8F9FA),
      body: FutureBuilder(
          future: cloudInstance.collection(widget.userID.uid).get(),
          builder: (BuildContext ctx,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (snapshot.data!.size == 0) {
                cloudInstance.collection(widget.userID.uid).add({
                  "topic": "Welcome",
                  "content":
                      "Welcome to Fire-Logs. Here you can add, edit or delete your logs",
                  "created-on": DateTime.now(),
                  "colormap": math.Random().nextInt(8),
                  "maxLines": 5 + math.Random().nextInt(5),
                  "inTrash": false,
                  "can_delete": false,
                });
              }
              return NotesList(
                userId: widget.userID.uid,
              );
            } else {
              return Center(
                child: spinkit.SpinKitChasingDots(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditNote(
                  isNew: true,
                  topic: "",
                  content: "",
                  createdOn: DateTime.now(),
                  colorMap: math.Random().nextInt(8),
                  docId: "",
                  userId: widget.userID.uid,
                  canDelete: true,
                ))),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorDark,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_rounded,
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
      // floatingActionButton: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     GestureDetector(
      //       onTap: () => Navigator.of(context)
      //           .push(MaterialPageRoute(builder: (_) => const UploadPage())),
      //       child: Container(
      //         padding: const EdgeInsets.all(15.0),
      //         decoration: BoxDecoration(
      //           color: Theme.of(context).brightness == Brightness.light
      //               ? Theme.of(context).primaryColor
      //               : Theme.of(context).primaryColorDark,
      //           shape: BoxShape.circle,
      //         ),
      //         child: Icon(
      //           Icons.camera,
      //           color: Theme.of(context).brightness == Brightness.light
      //               ? Theme.of(context).primaryColorDark
      //               : Theme.of(context).primaryColor,
      //         ),
      //       ),
      //     ),
      //     const SizedBox(width: 50.0),
      //     GestureDetector(
      //       onTap: () => Navigator.of(context).push(MaterialPageRoute(
      //           builder: (_) => EditNote(
      //                 isNew: true,
      //                 topic: "",
      //                 content: "",
      //                 createdOn: DateTime.now(),
      //                 colorMap: math.Random().nextInt(8),
      //                 docId: "",
      //                 userId: widget.userID.uid,
      //                 canDelete: true,
      //               ))),
      //       child: Container(
      //         padding: const EdgeInsets.all(15.0),
      //         decoration: BoxDecoration(
      //           color: Theme.of(context).brightness == Brightness.light
      //               ? Theme.of(context).primaryColor
      //               : Theme.of(context).primaryColorDark,
      //           shape: BoxShape.circle,
      //         ),
      //         child: Icon(
      //           Icons.add_rounded,
      //           color: Theme.of(context).brightness == Brightness.light
      //               ? Theme.of(context).primaryColorDark
      //               : Theme.of(context).primaryColor,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        height: 20.0,
        alignment: Alignment.center,
        child: Container(
          width: 150.0,
          height: 4.0,
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Colors.white
                : Colors.black,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
        ),
      ),
    );
  }
}
