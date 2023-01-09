import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;

import 'widgets/note_preview.dart';

class NotesList extends StatefulWidget {
  const NotesList({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: cloudInstance
          .collection(widget.userId)
          .orderBy('created-on')
          // .where('inTrash', isEqualTo: false)
          .snapshots(),
      builder:
          (BuildContext ctx, AsyncSnapshot<QuerySnapshot<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              const Center(
                child: spinkit.SpinKitChasingDots(
                  color: Colors.greenAccent,
                ),
              ),
              Text(
                "Probably no items here!",
                style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white24
                        : Colors.black26,
                    fontSize: 16.0),
              )
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: spinkit.SpinKitChasingDots(
              color: Colors.indigoAccent,
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // List<QueryDocumentSnapshot<dynamic>> allDocuments =
            //     snapshot.data!.docs;
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
              return (e.data()!['inTrash'] == false);
            }).toList();

            List secondColumnWidgets = allDocuments
                .getRange(firstColumnLength, allDocuments.length)
                .where((e) {
              return (e.data()!['inTrash'] == false);
            }).toList();

            log(firstColumnWidgetsID.toString());
            log(secondColumnWidgetsID.toString());

            log("firstColumnWidgets Length: ${firstColumnWidgets.length}");
            log("secondColumnWidgets length: ${secondColumnWidgets.length}");

            return SafeArea(
                child: SingleChildScrollView(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(firstColumnWidgets.length, (index) {
                      return NoteWidget(
                        topic: firstColumnWidgets[index].data()!['topic'],
                        content: firstColumnWidgets[index].data()!['content'],
                        createdOn: firstColumnWidgets[index]
                            .data()!['created-on']
                            .toDate(),
                        colorMap: firstColumnWidgets[index].data()!['colormap'],
                        maxLines: firstColumnWidgets[index].data()!['maxLines'],
                        docId: firstColumnWidgets[index].id,
                        userId: widget.userId,
                        inTrash: firstColumnWidgets[index].data()!['inTrash'],
                        canDelete:
                            firstColumnWidgets[index].data()!['can_delete'],
                      );
                    }),
                  ),
                  (secondColumnWidgets.isNotEmpty)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(secondColumnWidgets.length,
                              (index) {
                            return NoteWidget(
                                topic:
                                    secondColumnWidgets[index].data()!['topic'],
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
    );
  }
}
