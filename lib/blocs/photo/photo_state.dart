import 'dart:io';

abstract class PhotoState {}

class PhotoInitial extends PhotoState {}

class PhotosLoaded extends PhotoState {
  final List<File> photos;
  PhotosLoaded(this.photos);
}

class PhotoOperationSuccess extends PhotoState {}

class PhotoOperationFailure extends PhotoState {
  final String error;
  PhotoOperationFailure(this.error);
}
