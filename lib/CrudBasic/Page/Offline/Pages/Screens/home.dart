// ignore_for_file: use_build_context_synchronously

import 'package:demoapp/CrudBasic/Page/Offline/Pages/Model/noteModel.dart';
import 'package:demoapp/CrudBasic/Page/Offline/Pages/Service/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/Offline/Pages/Shared/topContainer.dart';
import 'package:demoapp/CrudBasic/Page/Offline/Pages/Views/note_view.dart';
import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeSqlLite extends StatefulWidget {
  final String title;

  const HomeSqlLite({super.key, required this.title});

  @override
  State<HomeSqlLite> createState() => _HomeSqlLiteState();
}

class _HomeSqlLiteState extends State<HomeSqlLite> {
  // Create an instance of the database helper
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<NoteModel> notes = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<NoteModel> filteredNotes = []; // Maintain a list for filtered notes

  @override
  void initState() {
    refreshNotes();
    search();
    super.initState();
  }

  @override
  dispose() {
    // Close the database when no longer needed
    noteDatabase.close();
    super.dispose();
  }

  // Search methods
  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          // Perform filtering and update the filteredNotes list
          filteredNotes = notes.where((note) {
            return note.title!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                note.description!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          // Clear the filteredNotes list
          filteredNotes.clear();
        }
      });
    });
  }

  // Fetch and refresh the list of notes from the database
  refreshNotes() {
    noteDatabase.getAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  // Navigate to the NoteView screen and refresh notes afterward
  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteView(noteId: id)),
    );
    refreshNotes();
  }

  deleteNote({int? id}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Row(children: [
              Icon(
                Icons.delete_forever,
                color: Color.fromARGB(255, 255, 81, 0),
              ),
              Text('Delete permanently!')
            ]),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure, you want to delete this note?'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () async {
                  await noteDatabase.delete(id!);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Note successfully deleted."),
                    backgroundColor: Color.fromARGB(255, 235, 108, 108),
                  ));
                  refreshNotes();
                },
                child: const Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 250, 252, 1.0),
      body: Column(
        children: <Widget>[
          TopContainer(
            height: 200,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircularPercentIndicator(
                          radius: 110.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: 0.75,
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: const Color.fromRGBO(251, 99, 64, 1.0),
                          backgroundColor:
                              const Color.fromRGBO(94, 114, 228, 1.0),
                          center: const CircleAvatar(
                            backgroundColor: Color.fromRGBO(82, 95, 127, 1.0),
                            radius: 45.0,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // ignore: avoid_unnecessary_containers
                            Container(
                              child: const Text(
                                'Flux Digital',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Color.fromRGBO(247, 250, 252, 1.0),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Text(
                              'Good software, takes time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ]),
          ),
          // Search TextField with Conditional Clear Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Notes...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (isSearchTextNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // Clear the search text and update the UI
                      searchController.clear();
                      // Reset the filteredNotes list and refresh the original notes
                      filteredNotes.clear();
                      refreshNotes();
                    },
                  ),
              ],
            ),
          ),
          // Scrollable area for displaying notes
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: notes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              "No records to display",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (isSearchTextNotEmpty)
                                ...filteredNotes.map((note) {
                                  // Display filtered notes
                                  return buildNoteCard(note);
                                }).toList()
                              else
                                ...notes.map((note) {
                                  // Display original notes when not searching
                                  return buildNoteCard(note);
                                }).toList(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating action button for creating new notes
      floatingActionButton: FloatingActionButton(
        onPressed: goToNoteDetailsView,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to build a note card
  Widget buildNoteCard(NoteModel note) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: const Icon(
            Icons.note,
            color: Color.fromARGB(255, 253, 237, 89),
          ),
          title: Text(note.title ?? ""),
          subtitle: Text(note.description ?? ""),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => goToNoteDetailsView(id: note.id),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
              IconButton(
                onPressed: () => deleteNote(id: note.id),
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 81, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to define subheading text style
  Text subheading(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Color.fromRGBO(94, 114, 228, 1.0),
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}
