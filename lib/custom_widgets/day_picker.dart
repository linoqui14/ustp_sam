
import 'package:flutter/material.dart';
import 'package:ustp_sam/custom_widgets/custom_textbutton.dart';
import 'package:ustp_sam/tools/my_colors.dart';

class CustomDayPicker extends StatefulWidget{
  const CustomDayPicker({Key? key,required this.value,required this.onSelect,this.padding = EdgeInsets.zero}) : super(key: key);
  final EdgeInsets padding;
  final int value;
  final Function(int) onSelect;
  static String intToDay(int day){
    switch(day){
      case 0:
        return "Mon";
      case 1:
        return "Tue";
      case 2:
        return "Wed";
      case 3:
        return "Thu";
      case 4:
        return "Fri";
      case 5:
        return "Sat";
      case 6:
        return "Sun";
      default:
        return "";
    }
  }
  @override
  State<CustomDayPicker> createState() => _CustomDayPickerState();
}

class _CustomDayPickerState extends State<CustomDayPicker>{
  int d = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          CustomTextButton(
              color: d==0?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Mon",
              onPressed: (){
                setState(() {
                  d = 0;
                  widget.onSelect(0);
                });

              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==1?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Tues",
              onPressed: (){
                setState(() {
                  d = 1;
                  widget.onSelect(1);
                });

              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==2?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Wed",
              onPressed: (){
                setState(() {
                  d = 2;
                  widget.onSelect(2);
                });

              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==3?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Thu",
              onPressed: (){
                setState(() {
                  d = 3;
                  widget.onSelect(3);
                });

              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==4?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Fri",
              onPressed: (){
                setState(() {
                  d = 4;
                  widget.onSelect(4);
                });
              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==5?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Sat",
              onPressed: (){
                setState(() {
                  d = 5;
                  widget.onSelect(5);
                });

              }
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          CustomTextButton(
              color: d==6?MyColors.darkBlue:MyColors.deadBlue,
              width: 50,
              text: "Sun",
              onPressed: (){
                setState(() {
                  d = 6;
                  widget.onSelect(6);
                });

              }
          ),
        ],
      ),
    );
  }

}