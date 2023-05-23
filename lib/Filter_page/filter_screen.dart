import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tn/Filter_page/rage_view_m.dart';
import 'package:tn/Filter_page/range_view.dart';
import 'package:tn/Recherche_pages/view_maps.dart';
import 'package:tn/Widgets/calendar_popup_view.dart';

import 'package:tn/Recherche_pages/listFilter.dart';
import 'filter_liste.dart';


// ignore: must_be_immutable
class FiltersScreen extends StatefulWidget {
  FiltersScreen({
    this.filter,this.titel,this.map,});
  int map;
  String titel;
  final  filter;
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  List<PopularFilterListData> popularFilterListData =
      PopularFilterListData.popularFList;
  List<PopularFilterListData> accomodationListData =
      PopularFilterListData.accomodationList;

  int groupe=0;

  List<String> listee;

  bool v=true;

  int groupe2;


  List<int> typee=[];
  @override
  void initState() {
    typee=[];
    listee=[];
    print(typee);
    popularFilterListData.forEach((element) {element.isSelected=false;});
    accomodationListData.forEach((element) {element.isSelected=false;});
    super.initState();
  }

  void a(int a){
    setState(() {
      groupe2=a;
    });
  }
  void f(int a){
    setState(() {
      groupe=a;
    });
  }
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  RangeValues _values = const RangeValues(50, 500);
  RangeValues _value = const RangeValues(300, 3000);
  double distValue ;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,

      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: <Widget>[
            getAppBarUI(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    priceBarFilter(),
                    const Divider(
                      height: 1,
                    ),
                    popularFilter(),
                    const Divider(
                      height: 1,
                    ),
                    allAccommodationUI(),

                    const Divider(
                      height: 1,
                    ),
                    distanceViewUI(),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    highlightColor: Colors.transparent,
                    onTap: () {
                      widget.map!=2?Navigator.of( context ).push( MaterialPageRoute(
                          builder: (context) => ListFilter(title:widget.titel,groupe:groupe,
                              moisStart:_value.start.toInt(),moisEnd:_value.end.toInt(),
                              jourStart:_values.start.toInt(),jourend:_values.end.toInt(),
                              groupe2: groupe2==1?true:false,dateStart:startDate,dateEnd:endDate,
                              list:listee,type:typee ) ) )
                          :Navigator.of( context ).push( MaterialPageRoute(
                          builder: (context) => ViewMaps(title:widget.titel,groupe:groupe,
                              moisStart:_value.start.toInt(),moisEnd:_value.end.toInt(),
                              jourStart:_values.start.toInt(),jourend:_values.end.toInt(),
                              groupe2: groupe2==1?true:false,dateStart:startDate,dateEnd:endDate,
                              list:listee,type:typee ) ) );

                    },
                    child: Center(
                      child: Text(
                        tr("trouve"),
                        style: tr("add_type") == "Type"
                            ? TextStyle(fontWeight: FontWeight.normal, fontSize: 18,color: Colors.white,)
                            : TextStyle(fontWeight: FontWeight.w700, fontSize: 22,color: Colors.white,),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget allAccommodationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            tr("typeh"),

            style:tr("add_type") == "Type"
                ? TextStyle(fontWeight: FontWeight.normal, fontSize: 18,color: Colors.grey,)
                : TextStyle(fontWeight: FontWeight.w700, fontSize: 22,color: Colors.grey,),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: getAccomodationListUI(),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  List<Widget> getAccomodationListUI() {
    final List<Widget> noList=[];
    noList.clear();
    for (int i = 0; i < accomodationListData.length; i++) {
      final PopularFilterListData date = accomodationListData[i];

      noList.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            onTap: () {

              setState(() {
                checkAppPosition(i);
              });
            },
            child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          tr(date.titleTxt),style: tr( "add_type" ) == "Type"
                          ? TextStyle( fontWeight: FontWeight.w400,
                        fontSize: date.titleTxt.length >= 14
                            ? 15
                            : 14, )
                          : TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 17 ),
                          textAlign: TextAlign.end
                      ),
                    ),
                    CupertinoSwitch(
                      activeColor: date.isSelected
                          ? Colors.teal
                          : Colors.grey.withOpacity(0.6),
                      onChanged: (bool value) {

                        setState(() {
                          checkAppPosition(i);

                        });

                      },
                      value: date.isSelected,
                    ),
                  ],
                )

            ),
          ),
        ),
      );
      if (i == 0) {

        noList.add(const Divider(
          height: 1,
        ));
      }
    }
    return noList;
  }

  void checkAppPosition(int index) {
    if (index == 0) {
      if (accomodationListData[0].isSelected) {
        accomodationListData.forEach((d) {
          d.isSelected = false;

        });
        typee.clear();
      } else {
        accomodationListData.forEach((d) {
          d.isSelected = true;




        });
        typee.add(0);
        typee.add(1);
        typee.add(2);
        typee.add(3);
        typee.add(4);

      }
    } else {
      accomodationListData[index].isSelected =
      !accomodationListData[index].isSelected;

      int count = 0;
      for (int i = 0; i < accomodationListData.length; i++) {
        if (i != 0) {
          final PopularFilterListData data = accomodationListData[i];
          if (data.isSelected) {
            count += 1;
            if(typee.contains(accomodationListData[i].titleTxt=='Maison'?0:
            accomodationListData[i].titleTxt=='Appartement'?1: accomodationListData[i].titleTxt=='Villa'?2:accomodationListData[i].titleTxt=='studio'?3:4)==false)
              typee.add(accomodationListData[i].titleTxt=='Maison'?0:
              accomodationListData[i].titleTxt=='Appartement'?1: accomodationListData[i].titleTxt=='Villa'?2:accomodationListData[i].titleTxt=='studio'?3:4
              );
          }
          else typee.remove(accomodationListData[i].titleTxt=='Maison'?0:
          accomodationListData[i].titleTxt=='Appartement'?1: accomodationListData[i].titleTxt=='Villa'?2:accomodationListData[i].titleTxt=='studio'?3:4);
        }
      }

      if (count == accomodationListData.length - 1) {
        accomodationListData[0].isSelected = true;

      } else {
        accomodationListData[0].isSelected = false;
      }
    }
  }

  Widget distanceViewUI() {
    return Container(

      margin: EdgeInsets.all(10),

      child: InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            // setState(() {
            //   isDatePopupOpen = true;
            // });
            showDemoDialog(context: context);
          },
          child:Row(
            mainAxisAlignment:MainAxisAlignment.start
            ,
            children: <Widget>[
              Icon(Icons.calendar_today,size: 30,),const SizedBox(
                width: 8,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      tr("edate"),
                      style: tr("add_type") == "Type"
                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 18)
                          : TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,color: Colors.grey
                    ),
                  ),
                ],
              ),
            ],
          )

      ),
    );
  }

  Widget popularFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(

          padding:EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            tr("fp"),
            style:tr("add_type") == "Type"
                ? TextStyle(fontWeight: FontWeight.normal, fontSize: 18,color: Colors.grey,)
                : TextStyle(fontWeight: FontWeight.w700, fontSize: 22,color: Colors.grey,),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: getPList(),
          ),
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  List<Widget> getPList() {

    final List<Widget> noList = <Widget>[];
    int count = 0;
    const int columnCount = 2;
    for (int i = 0; i < popularFilterListData.length / columnCount; i++) {
      final List<Widget> listUI = <Widget>[];

      for (int i = 0; i < columnCount; i++) {
        try {
          final PopularFilterListData date = popularFilterListData[count];

          listUI.add(Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      setState(() {
                        date.isSelected = !date.isSelected;
                        if(date.isSelected==true){
                          setState(() {
                            date.isSelected=true;
                          });
                          listee.add(date.titleTxt);

                        }
                        else {listee.removeWhere((element)=>
                        element==date.titleTxt);
                        setState(() {
                          date.isSelected=false;
                        });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            date.isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: date.isSelected
                                ? Colors.teal
                                : Colors.grey.withOpacity(0.6),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                              tr(date.titleTxt),style:tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w400,
                            fontSize: date.titleTxt.length >= 14
                                ? 15
                                : 14, )
                              : TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 17 ),
                              textAlign: TextAlign.end
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
          count += 1;
        } catch (e) {
          print(e);
        }
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ));
    }
    return noList;
  }

  Widget priceBarFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Container(
          padding: const EdgeInsets.all(16.0),

          child:Text(
            tr("prix"),
            style: tr("add_type") == "Type"
                ? TextStyle(fontWeight: FontWeight.normal, fontSize: 18,color: Colors.grey,)
                : TextStyle(fontWeight: FontWeight.w700, fontSize: 22,color: Colors.grey,),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal:16.0),

          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal:16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tr("pj"), style: tr("add_type") == "Type"
                    ? TextStyle(fontWeight: FontWeight.w700, fontSize: 15,color: Colors.grey)
                    : TextStyle(fontWeight: FontWeight.w800, fontSize: 18,color: Colors.grey),
                ),
                Radio(value: 1,groupValue: groupe,  onChanged: (v){

                  f(v);

                  print(v);
                }),

                Text(tr("pm"), style: tr("add_type") == "Type"
                    ? TextStyle(fontWeight: FontWeight.w700, fontSize: 15,color: Colors.grey)
                    : TextStyle(fontWeight: FontWeight.w800, fontSize: 18,color: Colors.grey),
                ),
                Radio(value:2,groupValue: groupe, onChanged: (v){print(v);

                f(v);
                },),

              ],
            ),
          ),
        ),


        groupe==1
            ?
        RangeSliderView(
          values: _values,
          onChangeRangeValues: (RangeValues values) {
            _values = values;
          },
        )
            :groupe==2?RangeSliderViewM(
          values: _value,
          onChangeRangeValues: (RangeValues values) {
            _value = values;
          },
        ):SizedBox(),


        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal:16.0),

          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal:16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tr("ascendant"), style: tr("add_type") == "Type"
                    ? TextStyle(fontWeight: FontWeight.w700, fontSize: 15,color: Colors.grey)
                    : TextStyle(fontWeight: FontWeight.w800, fontSize: 18,color: Colors.grey),
                ),
                Radio(value: 2,groupValue: groupe2,  onChanged: (v){

                  a(v);

                  print(v);
                }),

                Text(tr("descendant"), style: tr("add_type") == "Type"
                    ? TextStyle(fontWeight: FontWeight.w700, fontSize: 15,color: Colors.grey)
                    : TextStyle(fontWeight: FontWeight.w800, fontSize: 18,color: Colors.grey),
                ),
                Radio(value:1,groupValue: groupe2, onChanged: (v){print(v);

                a(v);
                },),

              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget getAppBarUI() {
    return Container(
      color: Theme.of(context).appBarTheme.color,
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                tr("filtre"),textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ),
            Container(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
            )
          ],
        ),
      ),
    );
  }

  void showDemoDialog({BuildContext context}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick:(DateTime startData, DateTime endData) {
          setState(() {
            if (startData != null && endData != null) {
              startDate = startData;
              endDate = endData;
            }
          });
        },
        onCancelClick: () {},
      ),
    );
  }

}
