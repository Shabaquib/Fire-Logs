import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data_models/global_data.dart';
import 'edit_note.dart';

class ViewNote extends StatefulWidget {
  const ViewNote(
      {Key? key,
      required this.topic,
      required this.content,
      required this.createdOn,
      required this.colorMap,
      required this.docId,
      required this.userId,
      required this.canDelete})
      : super(key: key);
  final String topic;
  final String content;
  final DateTime createdOn;
  final int colorMap;
  final String docId;
  final String userId;
  final bool canDelete;

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          Visibility(
            visible: widget.canDelete,
            child: Row(
              children: [
                IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => EditNote(
                                  isNew: false,
                                  topic: widget.topic,
                                  content: widget.content,
                                  createdOn: widget.createdOn,
                                  colorMap: widget.colorMap,
                                  docId: widget.docId,
                                  userId: widget.userId,
                                  canDelete: widget.canDelete,
                                ))),
                    icon: const Icon(Icons.edit_rounded)),
                const SizedBox(
                  width: 5.0,
                ),
                IconButton(
                    onPressed: () {
                      if (widget.canDelete) {
                        cloudInstance
                            .collection(widget.userId)
                            .doc(widget.docId)
                            .update({"inTrash": true});
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_rounded)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.topic,
                  style: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "Last edited: ${DateFormat.yMMMMd('en-US').format(widget.createdOn)}",
                  style: const TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.content.replaceAll("\\n", "\n"),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? notesDarkThemeColors[widget.colorMap]
          : notesThemeColors[widget.colorMap],
    );
  }
}
