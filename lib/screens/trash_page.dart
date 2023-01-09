import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;

import '../data_models/global_data.dart';
import 'widgets/note_preview.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;

  List<String> trashIDs = [];

  _emptyBin() {
    for (var element in trashIDs) {
      cloudInstance.collection(widget.userId).doc(element).delete();
    }
  }

  void _revokeTrashDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(10.0),
            title: const Center(
              child: Text(
                "Empty trash?",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 60.0,
                  color: Colors.amber,
                ),
                SizedBox(height: 10.0),
                Text(
                  "Delete all notes here?",
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                onPressed: () {
                  _emptyBin();
                  Navigator.pop(context);
                  showToast(context, "Emptying");
                },
                child: const Text(
                  "Yes",
                  style: TextStyle(
                      color: Color(0xFFE9967A), fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "No",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trash",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _revokeTrashDialog(context);
            },
            icon: const Icon(
              Icons.delete_sweep_rounded,
            ),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: cloudInstance
            .collection(widget.userId)
            .orderBy('created-on')
            // .where('inTrash', isEqualTo: true)
            .snapshots(),
        builder:
            (BuildContext ctx, AsyncSnapshot<QuerySnapshot<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const Center(
              child: spinkit.SpinKitChasingDots(
                color: Colors.greenAccent,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: spinkit.SpinKitChasingDots(
                color: Colors.indigoAccent,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<dynamic>> allDocuments =
                  snapshot.data!.docs.reversed.toList();

              List<String> firstColumnWidgetsID = [];
              List<String> secondColumnWidgetsID = [];

              int firstColumnLength = (allDocuments.length % 2 == 0)
                  ? (allDocuments.length ~/ 2)
                  : ((allDocuments.length - 1) ~/ 2);
              firstColumnLength += 1;

              List firstColumnWidgets =
                  allDocuments.getRange(0, firstColumnLength).where((e) {
                return (e.data()!['inTrash']);
              }).toList();

              List secondColumnWidgets = allDocuments
                  .getRange(firstColumnLength, allDocuments.length)
                  .where((e) {
                return (e.data()!['inTrash']);
              }).toList();

              log(firstColumnWidgetsID.toString());
              log(secondColumnWidgetsID.toString());

              log("firstColumnWidgets Length: ${firstColumnWidgets.length}");
              log("secondColumnWidgets length: ${secondColumnWidgets.length}");

              if (firstColumnWidgets.isEmpty && secondColumnWidgets.isEmpty) {
                return SafeArea(
                    child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        size: 100.0,
                        color: (Theme.of(context).brightness == Brightness.dark)
                            ? Colors.white24
                            : Colors.black26,
                      ),
                      Text(
                        "No items in trash",
                        style: TextStyle(
                            color: (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? Colors.white24
                                : Colors.black26,
                            fontSize: 16.0),
                      )
                    ],
                  ),
                ));
              } else {
                return SafeArea(
                    child: SingleChildScrollView(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            List.generate(firstColumnWidgets.length, (index) {
                          trashIDs.add(
                              firstColumnWidgets[index].data()!['topic'] ?? "");
                          return NoteWidget(
                              topic: firstColumnWidgets[index].data()!['topic'],
                              content:
                                  firstColumnWidgets[index].data()!['content'],
                              createdOn: firstColumnWidgets[index]
                                  .data()!['created-on']
                                  .toDate(),
                              colorMap:
                                  firstColumnWidgets[index].data()!['colormap'],
                              maxLines:
                                  firstColumnWidgets[index].data()!['maxLines'],
                              docId: firstColumnWidgets[index].id,
                              userId: widget.userId,
                              inTrash:
                                  firstColumnWidgets[index].data()!['inTrash'],
                              canDelete: firstColumnWidgets[index]
                                  .data()!['can_delete']);
                        }),
                      ),
                      (secondColumnWidgets.isNotEmpty)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  secondColumnWidgets.length, (index) {
                                // int customIndex = index + firstColumnLength;
                                trashIDs.add(secondColumnWidgets[index]
                                        .data()!['topic'] ??
                                    "");
                                return NoteWidget(
                                    topic: secondColumnWidgets[index]
                                        .data()!['topic'],
                                    content: secondColumnWidgets[index]
                                        .data()!['content'],
                                    createdOn: secondColumnWidgets[index]
                                        .data()!['created-on']
                                        .toDate(),
                                    colorMap: secondColumnWidgets[index]
                                        .data()!['colormap'],
                                    maxLines: secondColumnWidgets[index]
                                        .data()!['maxLines'],
                                    docId: secondColumnWidgets[index].id,
                                    userId: widget.userId,
                                    inTrash: secondColumnWidgets[index]
                                        .data()!['inTrash'],
                                    canDelete: secondColumnWidgets[index]
                                        .data()!['can_delete']);
                              }),
                            )
                          : const SizedBox(
                              width: 50.0,
                            )
                    ],
                  ),
                ));
              }
            } else {
              return const Center(
                child: spinkit.SpinKitChasingDots(
                  color: Colors.orangeAccent,
                ),
              );
            }
          } else {
            return const Center(
              child: spinkit.SpinKitChasingDots(
                color: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
