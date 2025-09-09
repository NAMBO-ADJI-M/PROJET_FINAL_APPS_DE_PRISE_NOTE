import 'package:flutter/material.dart';
import 'package:prise_de_note/user/note.dart';
import 'package:prise_de_note/database/database_manager.dart';
import 'package:prise_de_note/user/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ListeNoteScreen extends StatefulWidget {
  final List<Note> notes;

  const ListeNoteScreen({super.key, required this.notes});

  @override
  State<ListeNoteScreen> createState() => _ListeNoteScreenState();
}

class _ListeNoteScreenState extends State<ListeNoteScreen> {
  User? _utilisateur;
  File? _photoProfil;
  String _filtreActif = 'Toutes';

  @override
  void initState() {
    super.initState();
    _chargerUtilisateur();
  }

  Future<void> _chargerUtilisateur() async {
    final user = await DatabaseManager.instance.getConnectedUser();
    setState(() => _utilisateur = user);
  }

  Future<void> _choisirPhotoProfil() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoProfil = File(image.path));
    }
  }

  String _formaterDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    } catch (e) {
      return 'Date invalide';
    }
  }

  List<Note> _filtrerNotes() {
    switch (_filtreActif) {
      case 'Terminées':
        return widget.notes.where((note) => note.isDone).toList();
      case 'En cours':
        return widget.notes.where((note) => !note.isDone).toList();
      default:
        return widget.notes;
    }
  }

  Widget _buildFiltreChip(String label, IconData? icon, Color selectedColor) {
    final isSelected = _filtreActif == label;
    return RawChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected && icon != null)
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          if (isSelected && icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filtreActif = label),
      selectedColor: selectedColor,
      backgroundColor: Colors.white,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? selectedColor : Colors.grey.shade300,
        ),
      ),
    );
  }
  String _capitalize(String input) {
  if (input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}


  @override
  Widget build(BuildContext context) {
    final notesFiltrees = _filtrerNotes();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _choisirPhotoProfil,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: _photoProfil != null ? FileImage(_photoProfil!) : null,
                    child: _photoProfil == null
                        ? const Icon(Icons.person, color: Colors.blueAccent, size: 28)
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: _choisirPhotoProfil,
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.camera_alt_outlined, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
  child: Text(
    _utilisateur != null ? _capitalize(_utilisateur!.username) : '',
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    overflow: TextOverflow.ellipsis,
  ),
),

          ],
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              direction: Axis.horizontal,
              children: [
                _buildFiltreChip('Toutes', null, Colors.blueAccent),
                _buildFiltreChip('En cours', Icons.timelapse, Colors.blueAccent),
                _buildFiltreChip('Terminées', Icons.done, Colors.blueAccent),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: notesFiltrees.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucune note correspondant au filtre.'),
                    ),
                  )
                : ListView.builder(
                    itemCount: notesFiltrees.length,
                    itemBuilder: (context, index) {
                      final note = notesFiltrees[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            note.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: note.isDone ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                          
                              color: note.isDone ? Colors.grey : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formaterDate(note.createdAt),
                                style: const TextStyle(fontSize: 10),
                              ),
                              if (note.isDone)
                                const Text(
                                  '✅ Tâche terminée',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              if (note.deadline != null)
                                Text(
                                  'À faire avant le ${_formaterDate(note.deadline!)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
