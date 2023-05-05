import 'package:chat/resources/widget.dart';
import 'package:chat/screens/bottomSheet/BottomSheet.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:chat/utils/CustomValidators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key, this.userName}) : super(key: key);
  final String? userName;

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final TextEditingController textEditingController = TextEditingController();

  final feedbackKey = GlobalKey<FormState>();

  double? ratingFeedback;
  String? message;
  final user = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          titleText: "Send Your Feedback",
          context: context,
          isBack: true,
          color: Colors.transparent,
          textStyleColor: Colors.black),
      body: Form(
        key: feedbackKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sizeBoxH60(),
                // GIVE FEEDBACK TEXT
                _giveFeedbackText(),
                sizeBoxH25(),
                // HOW YOU FEEL IT  TEXT
                _howYouFeelItText(),
                sizeBoxH25(),
                // EMOJI SYMBOLS
                _buildEmoji(),
                sizeBoxH25(),
                // TELL US MORE ABOUT IT TEXT
                _telUsMoreAboutItText(),
                sizeBoxH15(),
                // FEED BACK TEXT FIELD
                _feedbackTextField(context),
                sizeBoxH25(),
                // PUBLISH FEEDBACK BUTTON
                _publishFeedBackButton(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PUBLISH BUTTON EXTRACT AS A METHOD
  Center _publishFeedBackButton(BuildContext context) {
    return Center(
      child: reusableButton(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.75,
          onTap: () {
            publish();
          },
          text: "Publish Feedback"),
    );
  }

  // FEEDBACK TEXT FIELD EXTRACT AS A METHOD
  Center _feedbackTextField(BuildContext context) {
    return Center(
      child: Container(
        height: 220,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: TextFormField(
          controller: textEditingController,
          decoration: const InputDecoration.collapsed(
            hintText: "Enter Your Feedback",
          ),
          minLines: 1,
          maxLines: 11,
          onChanged: (val) {
            setState(() {
              message = val;
            });
          },
          validator: (val) => CustomValidators.empty(val),
        ),
      ),
    );
  }

  // TELL US MORE ABOUT IT TEXT EXTRACT AS A METHOD
  Padding _telUsMoreAboutItText() {
    return Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: normalText(text: "Tell Us More About it"));
  }

  // EMOJI SYMBOLS EXTRACT AS A METHOD
  Center _buildEmoji() {
    return Center(
      child: RatingBar.builder(
        initialRating: 0,
        itemSize: 55,
        itemCount: 5,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const Icon(
                Icons.sentiment_dissatisfied_outlined,
                color: Colors.red,
              );
            case 1:
              return const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return const Icon(
                Icons.sentiment_neutral_rounded,
                color: Colors.amber,
              );
            case 3:
              return const Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.lightGreen,
              );
            case 4:
              return const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return Container();
          }
        },
        onRatingUpdate: (rating) {
          setState(() {
            ratingFeedback = rating;
          });
        },
      ),
    );
  }

  // HOW YOU FEEL IT TEXT EXTRACT AS A METHOD
  Padding _howYouFeelItText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: normalText(text: "How You Feel It ? "),
    );
  }

  // GIVE FEEDBACK TEXT EXTRACT AS A METHOD
  Padding _giveFeedbackText() {
    return const Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Text("Give  FeedBack",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  void getFeedback() async {
    await DatabaseServices(uid: user).createFeedback(
        user, widget.userName!, message!, ratingFeedback.toString());
  }

  void publish() {
    if (ratingFeedback == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Please Give Me A Rating',
      );
    }
    if (feedbackKey.currentState!.validate() && ratingFeedback != null) {
      getFeedback();
      QuickAlert.show(
        onConfirmBtnTap: () {
          nextPagePushAndRemoveUntil(
              context,
              BottomSheetTest(
                screenIndex: 2,
                isProfileScreen: true,
              ));
        },
        context: context,
        type: QuickAlertType.success,
        text: 'Feedback Publish Successfully',
      );
      textEditingController.clear();
    }
  }
}
