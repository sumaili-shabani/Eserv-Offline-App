class NoteModel {
  final int? noteId;
  final String noteTitle;
  final String noteContent;
  final String noteCode;
  final String createdAt;
  final int? noteEtat;

  NoteModel({
    this.noteId,
    this.noteEtat,
    required this.noteTitle,
    required this.noteContent,
    required this.noteCode,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> json) => NoteModel(
        noteId: json["noteId"],
        noteEtat: json["noteEtat"],
        noteTitle: json["noteTitle"],
        noteContent: json["noteContent"],
        noteCode: json["noteCode"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "noteId": noteId,
        "noteEtat": noteEtat,
        "noteTitle": noteTitle,
        "noteContent": noteContent,
        "noteCode": noteCode,
        "createdAt": createdAt,
      };
}
