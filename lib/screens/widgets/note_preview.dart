import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_models/global_data.dart';
import '../view_note.dart';

class NoteWidget extends StatefulWidget {
  NoteWidget(
      {Key? key,
      required this.topic,
      required this.content,
      required this.createdOn,
      required this.colorMap,
      required this.maxLines,
      required this.docId,
      required this.userId,
      required this.inTrash,
      required this.canDelete})
      : super(key: key);
  final String topic;
  final String content;
  final DateTime createdOn;
  final int colorMap;
  final int maxLines;
  final String docId;
  final String userId;
  final bool inTrash;
  final bool canDelete;

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.5,
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _isVisible = true;
          });
        },
        onTap: () {
          if (!widget.inTrash) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ViewNote(
                      topic: widget.topic,
                      content: widget.content,
                      createdOn: widget.createdOn,
                      colorMap: widget.colorMap,
                      docId: widget.docId,
                      userId: widget.userId,
                      canDelete: widget.canDelete,
                    )));
          }
        },
        child: Stack(
          children: [
            Container(
              // margin: EdgeInsets.all(10.0),
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? notesDarkThemeColors[widget.colorMap]
                    : notesThemeColors[widget.colorMap]),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.topic == "Untitled")
                      ? const SizedBox(height: 2.0)
                      : Text(
                          widget.topic,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    widget.content.replaceAll('\\n', '\n'),
                    softWrap: true,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 25.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)),
                            child: IconButton(
                              onPressed: () {
                                if (widget.canDelete) {
                                  //find another logic
                                  if (widget.inTrash) {
                                    cloudInstance
                                        .collection(widget.userId)
                                        .doc(widget.docId)
                                        .update({"inTrash": false});
                                  } else {
                                    cloudInstance
                                        .collection(widget.userId)
                                        .doc(widget.docId)
                                        .update({"inTrash": true});
                                  }
                                } else {
                                  showToast(context,
                                      "Welcome message can't be deleted!");
                                }
                              },
                              icon: (widget.canDelete)
                                  ? (widget.inTrash)
                                      ? const Icon(
                                          Icons.restart_alt_outlined,
                                          size: 25.0,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          Icons.delete_rounded,
                                          size: 25.0,
                                          color: Colors.white,
                                        )
                                  : const Icon(
                                      Icons.delete_rounded,
                                      size: 25.0,
                                      color: Colors.white38,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: widget.inTrash,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white)),
                          child: IconButton(
                            onPressed: () {
                              cloudInstance
                                  .collection(widget.userId)
                                  .doc(widget.docId)
                                  .delete();
                            },
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
