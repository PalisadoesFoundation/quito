/* This is an abstraction service for picking up Photos/videos
Library used: image_picker (https://pub.dev/packages/image_picker)
Service usage: "add_post_view_model.dart"
*/

import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MultiMediaPickerService {
  MultiMediaPickerService() {
    _picker = ImagePicker();
    _fileStream = _fileStreamController.stream.asBroadcastStream();
  }

  //Local Variables
  final StreamController<File> _fileStreamController = StreamController();
  late Stream<File> _fileStream;
  late ImagePicker _picker;

  //Getters
  Stream get fileStream => _fileStream;

  Future<File?> getPhotoFromGallery({bool camera = false}) async {
    try {
      final _image = await _picker.getImage(
          source: camera ? ImageSource.camera : ImageSource.gallery);
      if (_image != null) return File(_image.path);
    } catch (e) {
      print(
          "MulitMediaPickerService : Exception occured while choosing photo from the gallery");
    }
    return null;
  }
}
