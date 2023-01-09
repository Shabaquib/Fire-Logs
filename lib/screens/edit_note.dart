import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../data_models/global_data.dart';

class EditNote extends StatefulWidget {
  EditNote(
      {Key? key,
      required this.isNew,
      required this.topic,
      required this.content,
      required this.createdOn,
      required this.colorMap,
      required this.docId,
      required this.userId,
      required this.canDelete})
      : super(key: key);
  final bool isNew;
  final String topic;
  final String content;
  final DateTime createdOn; //last edited
  final int colorMap;
  final String docId;
  final String userId;
  final bool canDelete;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  FirebaseFirestore cloudInstance = FirebaseFirestore.instance;
  TextEditingController topicController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  int groupValue = 0;
  bool _isVisible = false;

  @override
  void initState() {
    groupValue = widget.colorMap;
    topicController.text = (widget.isNew) ? "" : widget.topic;
    contentController.text = (widget.isNew) ? "" : widget.content;
    super.initState();
  }

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
          IconButton(
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
            icon: Container(
              width: 23.0,
              height: 23.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    width: 3.0),
                color: Theme.of(context).brightness == Brightness.dark
                    ? notesDarkThemeColors[groupValue]
                    : notesThemeColors[groupValue],
              ),
              child: Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          (widget.isNew)
              ? IconButton(
                  onPressed: () async {
                    if (contentController.text.isNotEmpty) {
                      var id =
                          await cloudInstance.collection(widget.userId).add({
                        "topic": topicController.text.isNotEmpty
                            ? topicController.text
                            : "Untitled",
                        "content": contentController.text,
                        "created-on": DateTime.now(),
                        "colormap": groupValue,
                        "maxLines": 5 + math.Random().nextInt(5),
                        "inTrash": false,
                        "can_delete": true,
                      });
                    } else {
                      showToast(context, "Can't save empty notes");
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save_rounded))
              : IconButton(
                  onPressed: () async {
                    if (contentController.text.isNotEmpty) {
                      await cloudInstance
                          .collection(widget.userId)
                          .doc(widget.docId)
                          .update({
                        "topic": topicController.text.isNotEmpty
                            ? topicController.text
                            : "Untitled",
                        "content": contentController.text,
                        "created-on": DateTime.now(),
                        "colormap": groupValue,
                        "maxLines": 5 + math.Random().nextInt(5),
                        "can_delete": true,
                        "inTrash": false,
                      });
                    } else {
                      await cloudInstance
                          .collection(widget.userId)
                          .doc(widget.docId)
                          .delete();
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded)),
          const SizedBox(width: 10.0),
        ],
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? notesDarkThemeColors[groupValue]
          : notesThemeColors[groupValue],
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            color: Theme.of(context).brightness == Brightness.dark
                ? notesDarkThemeColors[groupValue]
                : notesThemeColors[groupValue],
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "Last edited: ${DateFormat.yMMMMd('en-US').format(widget.createdOn)}",
                      style: const TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: topicController,
                      minLines: 1,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black45,
                      cursorRadius: const Radius.circular(1.0),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? notesDarkThemeColors[groupValue]
                                : notesThemeColors[groupValue],
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: "Enter topic here!",
                        hintStyle: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: contentController,
                    minLines: 2,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    cursorColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                    cursorRadius: const Radius.circular(1.0),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? notesDarkThemeColors[groupValue]
                          : notesThemeColors[groupValue],
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintText: "Enter content here!",
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _isVisible,
            child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    height: 70.0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Transform.scale(
                            scale: 1.3,
                            child: Radio(
                                value: index,
                                groupValue: groupValue,
                                fillColor: MaterialStateColor.resolveWith(
                                  (states) => Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? notesDarkThemeColors[index]
                                      : notesThemeColors[index],
                                ),
                                activeColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? notesDarkThemeColors[index]
                                    : notesThemeColors[index],
                                onChanged: (index) {
                                  setState(() {
                                    groupValue = index as int;
                                  });
                                }),
                          );
                        },
                        separatorBuilder: (BuildContext ctx, int index) {
                          return const VerticalDivider(
                            thickness: 2.0,
                            color: Colors.white24,
                            indent: 15.0,
                            endIndent: 15.0,
                          );
                        },
                        itemCount: notesThemeColors.length))),
          ),
        ],
      ),
    );
  }
}
