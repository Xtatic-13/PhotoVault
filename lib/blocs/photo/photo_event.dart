import 'package:flutter/material.dart';

abstract class PhotoEvent {}

class AddPhoto extends PhotoEvent {}

class AddMultiplePhotos extends PhotoEvent {
  final BuildContext context;
  AddMultiplePhotos(this.context);
}

class DeletePhoto extends PhotoEvent {
  final String path;
  DeletePhoto(this.path);
}

class LoadPhotos extends PhotoEvent {}

class MovePhotoOut extends PhotoEvent {
  final List<String> paths;
  MovePhotoOut(this.paths);
}

class SharePhoto extends PhotoEvent {
  final String path;
  SharePhoto(this.path);
}

class PhotoMoved extends PhotoEvent {
  final String oldPath;
  final String newPath;
  PhotoMoved(this.oldPath, this.newPath);
}
