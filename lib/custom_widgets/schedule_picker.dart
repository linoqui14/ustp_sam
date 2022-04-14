

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:ustp_sam/model/schedule.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import 'package:ustp_sam/tools/my_dialog.dart';
import 'custom_texfield.dart';
import 'custom_textbutton.dart';
import 'day_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class SchedulePicker extends StatefulWidget{
  SchedulePicker({Key? key,required this.onSet,required this.widgetID}) : super(key: key);
  Function(Schedule,_SchedulePickerState) onSet;
  String widgetID;


  @override
  State<SchedulePicker> createState() => _SchedulePickerState();
}

class _SchedulePickerState extends State<SchedulePicker>{
  var uuid = Uuid();
  TextEditingController building = TextEditingController();
  TimeOfDay timeIn = TimeOfDay.now();
  TimeOfDay timeOut = TimeOfDay.now();
  int day = 0;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.darkBlue,width: 5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.widgetID,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 10),),
          CustomTextField(

            color: Colors.blue,
            controller: building,
            padding: EdgeInsets.symmetric(vertical: 10),
            hint: 'Building',

          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CustomDayPicker(
              onSelect: (d){
                setState((){
                  day = d;
                });
              },
              value: day,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextButton(
                  text: "Time-in",
                  onPressed: (){
                    Navigator.of(context).push(
                      showPicker(
                        context: context,
                        value: timeIn,

                        onChange: (TimeOfDay ) {
                          setState(() {
                            timeIn = TimeOfDay;
                            print(timeIn.hour);
                          });
                        },
                      ),
                    );
                  }
              ),
              CustomTextButton(
                  text: "Time-out",
                  onPressed: (){
                    Navigator.of(context).push(
                      showPicker(
                        context: context,
                        value: timeOut,
                        onChange: (value){
                          setState(() {
                            timeOut = value;
                          });

                        },
                      ),
                    );
                  }
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 3)),

              Text(CustomDayPicker.intToDay(day),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,height: 0.8),),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time-in",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                        Text(timeIn.format(context)
                          ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                        Text(timeOut.format(context)
                          ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                      ],
                    ),
                  ],
                ),
              ),

              CustomTextButton(
                  width: 300,
                  color: MyColors.darkBlue,
                  text: "Set",
                  onPressed: (){
                    if(building.text.isNotEmpty){
                      widget.onSet.call(Schedule(
                          id: widget.widgetID,
                          room: building.text,
                          inTime: ((timeIn.hour*60)+timeIn.minute),
                          outTime: ((timeOut.hour*60)+timeOut.minute),
                          day: day,
                          inTimeStr: timeIn.format(context),
                          outTimeStr: timeOut.format(context)
                      ),this);
                    }
                    else{
                      MyDialog().show(
                          context: context,
                          statefulBuilder: StatefulBuilder(
                              builder: (context,setState){
                                return AlertDialog(
                                  content: Text("Please Enter Building"),
                                  actions: [
                                    CustomTextButton(
                                      width: 50,
                                      color: MyColors.red,
                                      text: "Okay",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              }
                          )
                      );
                    }

                  }
              )


            ],
          )
        ],
      ),
    );
  }

}