
import 'package:easy_localization/public.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ChatUsersList extends StatefulWidget{
  String text;
  String secondaryText;
  String image;
  String time;
  bool isMessageRead=false;

  ChatUsersList({@required this.text,@required this.secondaryText,@required this.image,@required this.time,this.isMessageRead, });
  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {


  @override
  Widget build(BuildContext context) {
    DateTime d=DateTime.fromMillisecondsSinceEpoch(int.parse(widget.time));
    return Container(decoration: BoxDecoration(color: Colors.grey[400].withOpacity(0.1)),
      padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[

                CircleAvatar( maxRadius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: (widget.image == '')
                      ? AssetImage( "assets/default.png" )
                      : NetworkImage(
                    widget.image, )
                  ,
                ),
                SizedBox(width: 16,),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.text,style: TextStyle(color: Theme.of(context).cursorColor),),
                        SizedBox(height: 6,),
                        Text(widget.secondaryText,style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text('${DateFormat('dd').format(d)},${tr(DateFormat('MMM').format(d))} ${DateFormat('kk:mm').format(d)}',style: TextStyle(fontSize: 12,color: widget.isMessageRead?Colors.pink:Colors.grey.shade500),),
        ],
      ),
    );
  }
}