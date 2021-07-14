import 'dart:async';

import 'package:talawa/constants/routing_constants.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/view_model/base_view_model.dart';

class OrganizationFeedViewModel extends BaseModel {
  // Local caching variables for a session.
  // ignore: prefer_final_fields
  List<Post> _posts = [], _pinnedPosts = [];
  final Set<String> _renderedPostID = {};
  late String _currentOrgname = "";

  // Importing services.
  final NavigationService _navigationService = locator<NavigationService>();
  final UserConfig _userConfig = locator<UserConfig>();
  final PostService _postService = locator<PostService>();

  // Stream variables
  late StreamSubscription _currentOrganizationStreamSubscription;
  late StreamSubscription _postsSubscription;
  late StreamSubscription _updatePostSubscription;

  // Getters
  List<Post> get posts => _posts;
  List<Post> get pinnedPosts => _pinnedPosts;
  String get currentOrgName => _currentOrgname;

  // Setters
  void setCurrentOrganizationName(String updatedOrganization) {
    if (updatedOrganization != _currentOrgname) {
      _posts.clear();
      _renderedPostID.clear();
      _currentOrgname = updatedOrganization;
      notifyListeners();
    }
    // _postService.getPosts();
  }

  void fetchNewPosts() {
    _postService.getPosts();
  }

  void initialise() {
    // For caching/initalizing the current organization after the stream subsciption has canceled and the stream is updated
    _currentOrgname = _userConfig.currentOrg.name!;
    // ------
    // Attasching the stream subscription to rebuild the widgets automatically
    _currentOrganizationStreamSubscription = _userConfig.currentOrfInfoStream
        .listen((updatedOrganization) =>
            setCurrentOrganizationName(updatedOrganization.name!));

    _postsSubscription =
        _postService.postStream.listen((newPosts) => buildNewPosts(newPosts));

    _updatePostSubscription =
        _postService.updatedPostStream.listen((post) => updatedPost(post));
  }

  void initializeWithDemoData() {
    // final postJsonResult = postsDemoData;

    // ------
    // Calling function to ge the post for the only 1st time.
    // _postService.getPosts();

    // //fetching pinnedPosts
    // final pinnedPostJsonResult = pinnedPostsDemoData;
    // pinnedPostJsonResult.forEach((pinnedPostJsonData) {
    //   _pinnedPosts.add(Post.fromJson(pinnedPostJsonData));
    // });
  }

  void buildNewPosts(List<Post> newPosts) {
    _posts = newPosts;
    notifyListeners();
  }

  void navigateToIndividualPage(Post post) {
    _navigationService.pushScreen(Routes.individualPost, arguments: post);
  }

  void navigateToPinnedPostPage() {
    _navigationService.pushScreen(Routes.pinnedPostPage,
        arguments: _pinnedPosts);
  }

  @override
  void dispose() {
    // Canceling the subscription so that there will be no rebuild after the widget is disposed.
    _currentOrganizationStreamSubscription.cancel();
    _postsSubscription.cancel();
    _updatePostSubscription.cancel();
    super.dispose();
  }

  addNewPost(Post newPost) {
    _posts.insert(0, newPost);
    notifyListeners();
  }

  updatedPost(Post post) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].sId == post.sId) {
        _posts[i] = post;
        notifyListeners();
        break;
      }
    }
  }
}
