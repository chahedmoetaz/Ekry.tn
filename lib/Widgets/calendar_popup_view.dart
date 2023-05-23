import 'dart:ui';
import 'package:easy_localization/public.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'custom_calendar.dart';

class CalendarPopupView extends StatefulWidget {
  const CalendarPopupView(
      {Key key,
      this.initialStartDate,
      this.initialEndDate,
      this.onApplyClick,
      this.onCancelClick,
      this.barrierDismissible = true,
      this.minimumDate,
      this.maximumDate,})
      : super(key: key);

  final DateTime minimumDate;
  final DateTime maximumDate;
  final bool barrierDismissible;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onApplyClick;

  final Function onCancelClick;
  @override
  _CalendarPopupViewState createState() => _CalendarPopupViewState();
}

class _CalendarPopupViewState extends State<CalendarPopupView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  DateTime startDate;
  DateTime endDate;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    if (widget.initialStartDate != null) {
      startDate = widget.initialStartDate;
    }
    if (widget.initialEndDate != null) {
      endDate = widget.initialEndDate;
    }
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: animationController.value,
              child: InkWell(
                onTap: () {
                  if (widget.barrierDismissible) {
                    Navigator.pop(context);
                  }
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        tr("de"),
                                        textAlign: TextAlign.left,
                                        style:  tr("add_type") == "Type"
                                            ? TextStyle(fontWeight: FontWeight.w700, fontSize: 17,color: Colors.grey)
                                            : TextStyle(fontWeight: FontWeight.w800, fontSize: 22,color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        startDate != null
                                            ?'${tr(DateFormat('EEE')
                                            .format(startDate))},${DateFormat('dd')
                                            .format(startDate)} ${tr(DateFormat('MMM')
                                            .format(startDate))}'

                                            : '--/-- ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 74,
                                  width: 1,
                                  color: Colors.teal,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        tr("a"),
                                        style: tr("add_type") == "Type"
                                            ? TextStyle(fontWeight: FontWeight.w700, fontSize: 17,color: Colors.grey)
                                            : TextStyle(fontWeight: FontWeight.w800, fontSize: 22,color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        endDate != null
                                            ? '${tr(DateFormat('EEE')
                                                .format(endDate))},${DateFormat('dd')
                                            .format(endDate)} ${tr(DateFormat('MMM')
                                            .format(endDate))}'
                                            : '--/-- ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Divider(
                              height: 1,
                            ),
                            CustomCalendarView(
                              theme:Theme.of(context),
                              minimumDate: widget.minimumDate,
                              maximumDate: widget.maximumDate,
                              initialEndDate: widget.initialEndDate,
                              initialStartDate: widget.initialStartDate,
                              startEndDateChange: (DateTime startDateData,
                                  DateTime endDateData) {
                                setState(() {
                                  startDate = startDateData;
                                  endDate = endDateData;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 8),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black54.withOpacity(0.8),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 8,
                                      offset: const Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0)),

                                  onTap: () {
                                    try {
                                      // animationController.reverse().then((f) {

                                      // });
                                      widget.onApplyClick(startDate, endDate);
                                      Navigator.pop(context);
                                    } catch (_) {}
                                  },
                                  child: Center(
                                    child: Text(
                                      tr("appliquer"),
                                      textAlign: TextAlign.left,
                                      style:  tr("add_type") == "Type"
                                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 17,color: Colors.white)
                                          : TextStyle(fontWeight: FontWeight.w800, fontSize: 22,color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
