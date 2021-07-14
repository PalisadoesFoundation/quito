import 'package:flutter/material.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/after_auth_view_models/add_post_view_models/add_post_view_model.dart';
import 'package:talawa/views/base_view.dart';

// Global model state, should be removed soon
late AddPostViewModel model;

class AddPost extends StatelessWidget {
  const AddPost({Key? key, this.drawerKey}) : super(key: key);
  final GlobalKey<ScaffoldState>? drawerKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.9,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.strictTranslate('Share News'),
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => drawerKey!.currentState!.openDrawer(),
          ),
          actions: [
            TextButton(
              onPressed: () => model.uploadPost(),
              child: Text(
                AppLocalizations.of(context)!.strictTranslate("Post"),
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).accentColor),
              ),
            ),
          ],
        ),
        body: BaseView<AddPostViewModel>(
          onModelReady: (m) {
            m.initialise();
            model = m;
          },
          builder: (context, model, child) => Column(
            children: <Widget>[
              ListTile(
                leading: const CircleAvatar(radius: 25),
                title: Text(model.userName),
                subtitle: Text(AppLocalizations.of(context)!
                    .strictTranslate(model.orgName)),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                      onPressed: () => model.getImageFromGallery(),
                      icon: const Icon(Icons.photo)),
                  IconButton(
                      onPressed: () => model.getImageFromGallery(camera: true),
                      icon: const Icon(Icons.camera_alt)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.file_upload)),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        '# ${AppLocalizations.of(context)!.strictTranslate("Add hasthtag")}',
                        style: Theme.of(context).textTheme.headline6,
                      )),
                ],
              ),
              const Divider(),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: model.controller,
                  maxLines: null,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: AppLocalizations.of(context)!.strictTranslate(
                          "Write here what do you want to share")),
                ),
              )),
              model.imageFile != null
                  // ignore: sized_box_for_whitespace
                  ? Container(
                      height: 230,
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.file(
                            model.imageFile!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: IconButton(
                                onPressed: () => model.removeImage(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.black,
                                )),
                          )
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
