import 'package:flutter/material.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository.dart';
import 'package:notes_app/notes/view/notes_page.dart';
import 'package:notes_app/search/view/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.notesRepository, super.key});

  final NotesRepository notesRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final _pages = [
    NotesPage(notesRepository: widget.notesRepository),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
