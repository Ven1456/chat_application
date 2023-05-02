import 'dart:ffi';

import 'package:chat/resources/widget.dart';
import 'package:chat/utils/CustomValidators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedBackScreen extends StatefulWidget {
   FeedBackScreen({Key? key}) : super(key: key);

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final TextEditingController textEditingController = TextEditingController();

   final feedbackKey= GlobalKey<FormState>();

   double? ratingFeedback;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key:feedbackKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.arrow_back_ios_new_sharp),
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Text(
                        "Send your Feedback",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                      ),
                    )
                  ],
                ),
                sizeBoxH60(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text("Give  FeedBack",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                sizeBoxH25(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text("How You Feel It ? ",
                      style:
                          TextStyle(fontWeight: FontWeight.normal, fontSize: 15)),
                ),
                sizeBoxH25(),
                Center(
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
                ),
                sizeBoxH25(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text("Tell Us More About it",
                      style:
                          TextStyle(fontWeight: FontWeight.normal, fontSize: 15)),
                ),
                sizeBoxH15(),
                Center(
                  child: Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width * 0.85,
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
                      validator: (val)=> CustomValidators.empty(val),
                    ),
                  ),
                ),
                sizeBoxH25(),
                Center(
                  child: reusableButton(
                      50,
                      MediaQuery.of(context).size.width * 0.75,
                      () {
                        publish();
                      },
                      "Publish Feedback"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void publish(){
    if(feedbackKey.currentState!.validate()){
      setState(() {
        ratingFeedback.toString().isEmpty ? CircularProgressIndicator(): null;
      });

    }

  }
}
