import 'package:app/blocs/photo/photo_bloc.dart';
import 'package:app/blocs/photo/photo_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void photoOptions(BuildContext context, String path) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Photo Options'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: const Text('Move'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<PhotoBloc>().add(MovePhotoOut([path]));
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: const Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<PhotoBloc>().add(SharePhoto(path));
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<PhotoBloc>().add(DeletePhoto(path));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
