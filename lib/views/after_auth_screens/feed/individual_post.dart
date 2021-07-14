import 'package:flutter/material.dart';
import 'package:talawa/models/comment/comment_model.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/widgets_view_models/comments_view_model.dart';
import 'package:talawa/views/base_view.dart';
import 'package:talawa/widgets/post_widget.dart';

//Global Stete, should be removed in next few iterations
late CommentsViewModel _commentViewModel;

class IndividualPostView extends StatefulWidget {
  const IndividualPostView({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  _IndividualPostViewState createState() => _IndividualPostViewState();
}

class _IndividualPostViewState extends State<IndividualPostView> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      bottomSheet: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (msg) {
                  _commentViewModel.createComment(msg);
                  _controller.text = "";
                },
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  hintText: "Write your comment here..",
                  contentPadding: EdgeInsets.all(8.0),
                  focusColor: Colors.black,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            TextButton(
                onPressed: () {
                  _commentViewModel.createComment(_controller.text);
                  _controller.text = "";
                },
                child: const Text("Send"))
          ],
        ),
      ),
      body: ListView(
        children: [
          NewsPost(
            post: widget.post,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IndividualPageLikeSection(
                  usersLiked: widget.post.likedBy!,
                ),
                IndividualPostCommentSection(
                  comments: widget.post.comments!,
                  postID: widget.post.sId,
                ),
                const SizedBox(
                  height: 200,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Padding buildPadding(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      AppLocalizations.of(context)!.strictTranslate(text),
      style: Theme.of(context).textTheme.headline6,
    ),
  );
}

class IndividualPageLikeSection extends StatelessWidget {
  const IndividualPageLikeSection({
    Key? key,
    required this.usersLiked,
  }) : super(key: key);

  final List<LikedBy> usersLiked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPadding(context, "Liked by"),
        Row(
          children: [
            for (int i = 0; i < usersLiked.length; i++)
              likedUserCircleAvatar(usersLiked[i])
          ],
        ),
      ],
    );
  }
}

class IndividualPostCommentSection extends StatelessWidget {
  const IndividualPostCommentSection(
      {Key? key, required this.comments, required this.postID})
      : super(key: key);
  final List<Comments> comments;
  final String postID;

  @override
  Widget build(BuildContext context) {
    return BaseView<CommentsViewModel>(
      onModelReady: (model) {
        model.initialise(postID);
        _commentViewModel = model;
      },
      builder: (context, model, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPadding(context, "Comments"),
          for (int i = 0; i < model.commentList.length; i++)
            CommentTemplate(comment: model.commentList[i])
        ],
      ),
    );
  }
}

class CommentTemplate extends StatelessWidget {
  const CommentTemplate({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).iconTheme.color!.withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "${comment.creator!.firstName!} ${comment.creator!.lastName!}",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              Text(
                comment.text!,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 16.0),
              ),
            ],
          ),
        ))
      ],
    );
  }
}

Widget likedUserCircleAvatar(LikedBy user) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0, bottom: 16.0),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xfff2f2f2),
          radius: 20,
        ),
        const Positioned(
          top: 30,
          right: 0,
          bottom: 20,
          left: 20,
          child: Icon(
            Icons.thumb_up,
            color: Colors.blue,
            size: 20,
          ),
        ),
      ],
    ),
  );
}
