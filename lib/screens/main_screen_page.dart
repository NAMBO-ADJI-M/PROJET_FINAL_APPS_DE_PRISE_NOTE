import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prise_de_note/screens/liste_notes.dart';
import '../database/database_manager.dart';
import '../user/user.dart';
import '../user/note.dart';


class MainPageScreen extends StatefulWidget {
  final User currentUser;

  const MainPageScreen({super.key, required this.currentUser});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Note> _notes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    final userId = widget.currentUser.id;
    if (userId == null) {
      debugPrint("❌ ID utilisateur null");
      _setLoading(false);
      return;
    }

    try {
      final notes = await DatabaseManager.instance.getNotesByUserId(userId);

      // ✅ Tri par date de création décroissante
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() => _notes = notes);
      }
    } catch (e) {
      _showSnackBar('Erreur lors du chargement des notes: $e');
    } finally {
      _setLoading(false);
    }
  }
  String _capitalize(String input) {
  if (input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1);
}


  Future<void> _addNote() async {
    final user = await DatabaseManager.instance.getConnectedUser();

    if (user == null || user.id == null) {
      _showSnackBar('Erreur: utilisateur non connecté.');
      return;
    }

    final titreNote = _controller.text.trim();

    if (titreNote.isEmpty) {
      _showSnackBar('Veuillez saisir un titre.');
      return;
    }


    final nouvelleNote = Note(
      userId: user.id!,
      title: titreNote,
      isDone: false,
      createdAt: DateTime.now().toIso8601String(),
      deadline: null,
    );

    await _performAsyncOperation(() async {
      await DatabaseManager.instance.insertNote(nouvelleNote);
      _controller.clear();
      setState(() {
        _notes.insert(0, nouvelleNote); // ✅ Ajout en tête
      });
    }, 'Erreur lors de l\'ajout de la note.');
  }

  Future<void> _editNote(Note note) async {
    final controller = TextEditingController(text: note.title);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier la tâche'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nouveau titre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                note.title = newText;
                await _performAsyncOperation(() async {
                  await DatabaseManager.instance.updateNote(note);
                  await _loadNotes();
                }, 'Erreur lors de la mise à jour.');
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id != null) {
      await _performAsyncOperation(() async {
        await DatabaseManager.instance.deleteNote(note.id!);
        await _loadNotes();
      }, 'Erreur lors de la suppression.');
    }
  }

  Future<void> _toggleNote(Note note) async {
    if (note.id != null) {
      note.isDone = !note.isDone;
      await _performAsyncOperation(() async {
        await DatabaseManager.instance.updateNote(note);
        await _loadNotes();
      }, 'Erreur lors de la mise à jour de l\'état.');
    }
  }

  Future<void> _performAsyncOperation(
    Future<void> Function() operation,
    String errorMessage,
  ) async {
    try {
      await operation();
    } catch (e) {
      _showSnackBar('$errorMessage: $e');
    }
  }

  void _setLoading(bool isLoading) {
    if (mounted) {
      setState(() => _isLoading = isLoading);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(message)),
          duration: const Duration(seconds: 2),
        ),
      );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To do list',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context), // ✅ Retour à l’écran précédent
          tooltip: 'Retour',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.blue,
    onPressed: () {
      DatabaseManager.instance.setConnectedUser(widget.currentUser);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListeNoteScreen(notes: _notes),
        ),
      );
    },
    tooltip: 'Voir toutes les notes',
    child: const Icon(Icons.list, color: Colors.white),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // ✅ Centrage

      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Ferme le clavier au tap
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Text(
                  'Bienvenue ${_capitalize(widget.currentUser.username)}'
,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: const Color.fromARGB(255, 22, 97, 228),
                  ),
                ),
                // Barre d'ajout
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Ajouter une note',
                          border: UnderlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.task_outlined,
                            color: Colors.blue,
                          ), // Icône pour le champ de texte
                        ),
                        onSubmitted: (_) => _addNote(),
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.blue,
                      ), // Icône pour ajouter
                      onPressed: _addNote,
                      tooltip: 'Ajouter',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Indicateur de chargement
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),

                // Liste des notes
                if (!_isLoading)
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.6, // Hauteur fixe pour scroll
                    child: _notes.isEmpty
                        ? const Center(child: Text('Aucune note enregistrée'))
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (_, index) {
                              final note = _notes[index];
                              return Dismissible(
                                key: Key(note.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  color: Colors.lightBlue,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Confirmer la suppression',
                                      ),
                                      content: const Text(
                                        'Voulez-vous vraiment supprimer cette note ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) async {
                                  await _deleteNote(note);
                                  _showSnackBar(
                                    'Note "${note.title}" supprimée',
                                  );
                                },
                                child: Card(
                                  elevation: 1.5,
                                  surfaceTintColor: Colors.blue,
                                  shadowColor: const Color.fromARGB(
                                    255,
                                    26,
                                    139,
                                    196,
                                  ),
                                  child: ListTile(
                                    leading: IconButton(
  icon: Icon(
    note.isDone ? Icons.check_circle : Icons.circle_outlined,
    color: note.isDone ? Colors.green : Colors.grey,
  ),
  onPressed: () => _toggleNote(note),
  tooltip: note.isDone ? 'Marquer comme non terminée' : 'Marquer comme terminée',
),

                                    title: Text(
                                      note.title,
                                      style: TextStyle(
                                        decoration: note.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_formaterDate(note.createdAt)},',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                          ),
                                          onPressed: () => _editNote(note),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                  'Confirmer la suppression',
                                                ),
                                                content: const Text(
                                                  'Voulez-vous vraiment supprimer cette note ?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(false),
                                                    child: const Text(
                                                      'Annuler',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Supprimer',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await _deleteNote(note);
                                              _showSnackBar(
                                                'Tâche "${note.title}" supprimée',
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () => _toggleNote(note),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}