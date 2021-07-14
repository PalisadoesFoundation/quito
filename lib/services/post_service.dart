import 'dart:async';

import 'package:talawa/locator.dart';
import 'package:talawa/models/organization/org_info.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/utils/post_queries.dart';

class PostService {
  PostService() {
    _postStream = _postStreamController.stream.asBroadcastStream();
    _updatedPostStream =
        _updatedPostStreamController.stream.asBroadcastStream();
    _currentOrg = _userConfig.currentOrg;
    setOrgStreamSubscription();
    getPosts();
  }
  // Stream for entire posts
  final StreamController<List<Post>> _postStreamController =
      StreamController<List<Post>>();
  late Stream<List<Post>> _postStream;

  //Stream for individul post update
  final StreamController<Post> _updatedPostStreamController =
      StreamController<Post>();
  late Stream<Post> _updatedPostStream;

  final _userConfig = locator<UserConfig>();
  final _dbFunctions = locator<DataBaseMutationFunctions>();
  late OrgInfo _currentOrg;
  final Set<String> _renderedPostID = {};
  // ignore: prefer_final_fields
  List<Post> _posts = [];

  //Getters
  Stream<List<Post>> get postStream => _postStream;
  Stream<Post> get updatedPostStream => _updatedPostStream;

  //Setters
  void setOrgStreamSubscription() {
    _userConfig.currentOrfInfoStream.listen((updatedOrganization) {
      if (updatedOrganization != _currentOrg) {
        print("org changes from post service");
        _renderedPostID.clear();
        _currentOrg = updatedOrganization;
        getPosts();
      }
    });
  }

  //Function to get all posts
  Future<void> getPosts() async {
    final String currentOrgID = _currentOrg.id!;
    final String query = PostQueries().getPostsById(currentOrgID);
    final result = await _dbFunctions.gqlAuthQuery(query);

    //Checking if the dbFunctions return the postJSON, if not return.
    if (result.data!['postsByOrganization'] == null) return;

    final List postsJson = result.data!['postsByOrganization'] as List;

    final List<Post> _newPosts = [];
    postsJson.forEach((postJson) {
      final Post post = Post.fromJson(postJson as Map<String, dynamic>);
      if (!_renderedPostID.contains(post.sId)) {
        _newPosts.add(post);
        _renderedPostID.add(post.sId);
      }
    });
    _postStreamController.add(_newPosts);
    _posts = _newPosts;
  }

  // --- Functions related to Likes --- //
  Future<void> addLike(String postID) async {
    _localAddLike(postID);
    final String mutation = PostQueries().addLike();
    final result = await _dbFunctions
        .gqlAuthMutation(mutation, variables: {"postID": postID});
    print(result);
    return result;
  }

  void _localAddLike(String postID) {
    _posts.forEach((post) {
      if (post.sId == postID) {
        post.likedBy!.add(LikedBy(sId: _userConfig.currentUser.id));
        _updatedPostStreamController.add(post);
      }
    });
  }

  Future<void> removeLike(String postID) async {
    _removeLocal(postID);
    final String mutation = PostQueries().removeLike();
    final result = await _dbFunctions
        .gqlAuthMutation(mutation, variables: {"postID": postID});
    print(result);
    return result;
  }

  void _removeLocal(String postID) {
    _posts.forEach((post) {
      if (post.sId == postID) {
        post.likedBy!.removeWhere(
            (likeUser) => likeUser.sId == _userConfig.currentUser.id);
        _updatedPostStreamController.add(post);
      }
    });
  }

  // --- Functions related to comments --- //
  void addCommentLocally(String postID) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].sId == postID) {
        _posts[i].comments!.add(Comments(sId: postID));
        _updatedPostStreamController.add(_posts[i]);
      }
    }
  }
}
