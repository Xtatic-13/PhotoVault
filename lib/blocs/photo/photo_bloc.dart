import 'package:app/blocs/photo/photo_event.dart';
import 'package:app/blocs/photo/photo_state.dart';
import 'package:app/services/logger_service.dart';
import 'package:app/services/photo_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final PhotoService _photoService = PhotoService();
  final log = LoggerService().logger(PhotoService);

  PhotoBloc() : super(PhotoInitial()) {
    on<AddMultiplePhotos>(_onAddMultiplePhotos);
    on<DeletePhoto>(_onDeletePhoto);
    on<LoadPhotos>(_onLoadPhotos);
    on<MovePhotoOut>(_onMovePhotoOut);
    on<SharePhoto>(_onSharePhoto);

    add(LoadPhotos());
  }

  Future<void> _onAddMultiplePhotos(
      AddMultiplePhotos event, Emitter<PhotoState> emit) async {
    try {
      final newPaths =
          await _photoService.movePhotosToSecureFolder(event.context);
      if (newPaths.isNotEmpty) {
        emit(PhotoOperationSuccess());
        add(LoadPhotos());
      } else {
        log.w('Failed to move photos');
        emit(PhotoOperationFailure('Failed to move photos'));
      }
    } catch (e) {
      log.e(e.toString());
      emit(PhotoOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeletePhoto(
      DeletePhoto event, Emitter<PhotoState> emit) async {
    try {
      final success = await _photoService.deletePhotoFromFolder(event.path);
      if (success) {
        emit(PhotoOperationSuccess());
        add(LoadPhotos());
      } else {
        log.w('Failed to delete photo');
        emit(PhotoOperationFailure('Failed to delete photo'));
      }
    } catch (e) {
      log.e(e.toString());
      emit(PhotoOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadPhotos(LoadPhotos event, Emitter<PhotoState> emit) async {
    try {
      final photos = await _photoService.getSecurePhotos();
      emit(PhotosLoaded(photos));
    } catch (e) {
      log.e(e.toString());
      emit(PhotoOperationFailure(e.toString()));
    }
  }

  Future<void> _onMovePhotoOut(
      MovePhotoOut event, Emitter<PhotoState> emit) async {
    try {
      await _photoService.moveMultiplePhotosFromSecureFolder(event.paths);
      emit(PhotoOperationSuccess());
      add(LoadPhotos());
    } catch (e) {
      log.e(e.toString());
      emit(PhotoOperationFailure(e.toString()));
    }
  }

  Future<void> _onSharePhoto(SharePhoto event, Emitter<PhotoState> emit) async {
    try {
      final success =
          await _photoService.sharePhotoFromSecureFolder(event.path);
      if (success) {
        emit(PhotoOperationSuccess());
      } else {
        log.w("Failed to share photo");
        emit(PhotoOperationFailure('Failed to share photo'));
      }
    } catch (e) {
      log.e(e.toString());
      emit(PhotoOperationFailure(e.toString()));
    }
  }
}
