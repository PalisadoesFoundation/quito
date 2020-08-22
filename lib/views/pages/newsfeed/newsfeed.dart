import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'dart:math';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/apiFuctions.dart';
import 'package:talawa/views/pages/newsfeed/addPost.dart';
import 'package:talawa/views/pages/newsfeed/newsArticle.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/timer.dart';

class NewsFeed extends StatefulWidget {
  NewsFeed({Key key}) : super(key: key);

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List list = List<String>.generate(
      20, (int index) => lipsum.createWord(numWords: 4).toString());
  List list2 = List<String>.generate(
      20, (int index) => lipsum.createWord(numWords: 20).toString());
  List times = List<int>.generate(20, (index) => Random().nextInt(30));
////////////////////////////////////////////////////
  Preferences preferences = Preferences();
  ApiFunctions apiFunctions = ApiFunctions();
  List postList = [];
  String name;
  Timer timer = Timer();

  initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    final String currentOrgID = await preferences.getCurrentOrgId();
    String query = Queries().getPostsById(currentOrgID);
    Map result = await apiFunctions.gqlquery(query);
    // print(result);
    setState(() {
      postList =
          result == null ? [] : result['postsByOrganization'].reversed.toList();
    });
  }

  Future<void> addLike(String postID) async {
    String mutation = Queries().addLike(postID);
    Map result = await apiFunctions.gqlmutation(mutation);
    print(result);
    getPosts();
  }

  Future<void> removeLike(String postID) async {
    String mutation = Queries().removeLike(postID);
    Map result = await apiFunctions.gqlmutation(mutation);
    print(result);
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    times.sort();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Newsfeed',
            style: TextStyle(color: Colors.white),
          ),
        ),
        floatingActionButton: addPostFab(),
        body: postList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  getPosts();
                },
                child: ListView.builder(
                    itemCount: postList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    '${timer.hoursOrDays(postList[index]['createdAt'])}' +
                                        ' - ' +
                                        postList[index]['creator']
                                            ['firstName'] +
                                        ' ' +
                                        postList[index]['creator']['lastName']),
                              ),
                            ),
                            ListTile(
                                onTap: () {
                                  pushNewScreen(
                                    context,
                                    screen: NewsArticle(post: postList[index]),
                                  );
                                },
                                title:
                                    Text(postList[index]['title'].toString()),
                                subtitle:
                                    Text(postList[index]["text"].toString()),
                                trailing: Container(
                                  width: 80,
                                  child: Image.asset(UIData.shoppingImage),
                                )),
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      likeButton(index),
                                      commentCounter(index),
                                      Container(width: 80)
                                    ])),
                          ],
                        ),
                      );
                    })));
  }

  Widget addPostFab() {
    return FloatingActionButton(
        backgroundColor: UIData.secondaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          pushNewScreenWithRouteSettings(context,
              screen: AddPost(), settings: RouteSettings());
        });
  }

  Widget commentCounter(index) {
    return Row(
      children: [
        Text(
          postList[index]['commentCount'].toString(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        IconButton(
            icon: Icon(Icons.comment), color: Colors.grey, onPressed: () {})
      ],
    );
  }

  Widget likeButton(index) {
    return Row(
      children: [
        Text(
          postList[index]['likeCount'].toString(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        IconButton(
            icon: Icon(Icons.thumb_up),
            color: Colors.grey,
            onPressed: () {
              addLike(postList[index]['_id']);
            })
      ],
    );
  }
}