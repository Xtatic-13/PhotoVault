import 'dart:io';
import 'dart:typed_data';

import 'package:app/blocs/photo/photo_bloc.dart';
import 'package:app/blocs/photo/photo_event.dart';
import 'package:app/blocs/photo/photo_state.dart';
import 'package:app/presentation/widgets/photo_options_widget.dart';
import 'package:app/services/logger_service.dart';
import 'package:app/services/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedPhotos = {};
  final Map<String, Uint8List?> _photoCache = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Photos'),
        actions: [
          if (!_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.pushNamed(context, '/log_screen');
              },
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _selectionMode = true;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.move_to_inbox),
              onPressed: () => _moveSelectedPhotos(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSelectedPhotos(context),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selectedPhotos.clear();
                });
              },
            ),
          ],
        ],
      ),
      body: BlocBuilder<PhotoBloc, PhotoState>(
        builder: (context, state) {
          if (state is PhotosLoaded) {
            return _buildPhotoGrid(context, state.photos);
          } else if (state is PhotoOperationFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          context.read<PhotoBloc>().add(LoadPhotos());
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<PhotoBloc>().add(AddMultiplePhotos(context)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, List<File> photos) {
    return photos.isEmpty
        ? const Center(child: Text("No Photos to Show"))
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4, crossAxisSpacing: 4, crossAxisCount: 3),
            itemCount: photos.length,
            padding: const EdgeInsets.all(4),
            itemBuilder: (context, index) {
              final photo = photos[index];
              final isSelected = _selectedPhotos.contains(photo.path);
              return GestureDetector(
                onTap: _selectionMode
                    ? () => _togglePhotoSelection(photo.path)
                    : () {
                        LoggerService.logFileAccessed(photo.path);
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.memory(_photoCache[photo.path]!,
                                    fit: BoxFit.cover),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                onLongPress: _selectionMode
                    ? null
                    : () => photoOptions(context, photo.path),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _photoCache.containsKey(photo.path)
                        ? Image.memory(_photoCache[photo.path]!,
                            fit: BoxFit.cover)
                        : FutureBuilder<Uint8List?>(
                            future: PhotoService().getDecryptedPhoto(photo),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null) {
                                _photoCache[photo.path] = snapshot.data;
                                return Image.memory(snapshot.data!,
                                    fit: BoxFit.cover);
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                    if (_selectionMode)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.blue : Colors.white,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
  }

  void _togglePhotoSelection(String path) {
    setState(() {
      if (_selectedPhotos.contains(path)) {
        _selectedPhotos.remove(path);
      } else {
        _selectedPhotos.add(path);
      }
    });
  }

  void _moveSelectedPhotos(BuildContext context) {
    context.read<PhotoBloc>().add(MovePhotoOut(_selectedPhotos.toList()));
    _exitSelectionMode();
  }

  void _deleteSelectedPhotos(BuildContext context) {
    for (String path in _selectedPhotos) {
      context.read<PhotoBloc>().add(DeletePhoto(path));
    }
    _exitSelectionMode();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedPhotos.clear();
    });
  }
}
