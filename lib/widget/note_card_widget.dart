import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midterm2_shafina/model/note.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:midterm2_shafina/db/notes_database.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class NoteCardWidget extends StatefulWidget {
  final Note note;
  final int index;
  final VoidCallback onRatingUpdate;

  const NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  _NoteCardWidgetState createState() => _NoteCardWidgetState();
}

class _NoteCardWidgetState extends State<NoteCardWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.note.rating ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final color = _lightColors[widget.index % _lightColors.length];
    final time = DateFormat.yMMMd().format(widget.note.createdTime);
    final minHeight = getMinHeight(widget.index);

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 20.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
              onRatingUpdate: (rating) {
                setState(() {
                  _currentRating = rating;
                });
                // Assuming your Note class has a method to set the rating
                final updatedNote = widget.note.copy(rating: rating);
                NotesDatabase.instance.update(updatedNote);
                widget.onRatingUpdate();
              },
            ),
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              widget.note.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // ... any other children
          ],
        ),
      ),
    );
  }

  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }
}