import 'dart:io';

import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/organization/org_info.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/third_party_service/multi_media_pick_service.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/view_model/base_view_model.dart';

class AddPostViewModel extends BaseModel {
  //Services
  late MultiMediaPickerService _multiMediaPickerService;
  late NavigationService _navigationService;

  // ignore: unused_field
  late File? _imageFile;
  late User _currentUser;
  late OrgInfo _selectedOrg;
  final TextEditingController _controller = TextEditingController();

  // Getters
  File? get imageFile => _imageFile;
  String get userName => _currentUser.firstName! + _currentUser.lastName!;
  String get orgName => _selectedOrg.name!;
  TextEditingController get controller => _controller;

  void initialise() {
    _currentUser = locator<UserConfig>().currentUser;
    _navigationService = locator<NavigationService>();
    _selectedOrg = locator<UserConfig>().currentOrg;
    _imageFile = null;
    _multiMediaPickerService = locator<MultiMediaPickerService>();
  }

  Future<void> getImageFromGallery({bool camera = false}) async {
    final _image =
        await _multiMediaPickerService.getPhotoFromGallery(camera: camera);
    if (_image != null) {
      _imageFile = _image;
      notifyListeners();
    }
  }

  // Demo function that behaves of sending post to the backend, should be replaced when the backend is ready
  void uploadPost() {
    removeImage();
    _controller.text = "";
    _navigationService.showSnackBar("Post is uploaded");
  }

  void removeImage() {
    _imageFile = null;
    notifyListeners();
  }
}
