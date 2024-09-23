import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CommonComponents {
  static Widget queryTimeSlotData(
      BuildContext context,
      String prefixString,
      TextEditingController idController,
      double textFieldWidth,
      String textFieldHintText,
      DateTime startTime,
      Function(DateTime time) selectStartCallback,
      DateTime endTime,
      Function(DateTime time) selectEndCallback,
      [List<TextInputFormatter>? inputFormatters]) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Text(
            prefixString,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SizedBox(
              width: textFieldWidth,
              child: TextField(
                controller: idController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: textFieldHintText,
                ),
                keyboardType: TextInputType.number,
                // textAlign: TextAlign.center,
                inputFormatters: inputFormatters,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SizedBox(
              width: 310,
              child: TextButton(
                onPressed: () async {
                  DateTime? newTime = await showOmniDateTimePicker(
                    context: context,
                    initialDate: startTime,
                    firstDate:
                        DateTime(1600).subtract(const Duration(days: 3652)),
                    lastDate: DateTime.now().add(
                      const Duration(days: 3652),
                    ),
                    is24HourMode: true,
                    isShowSeconds: true,
                    minutesInterval: 1,
                    secondsInterval: 1,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                      maxHeight: 650,
                    ),
                    transitionBuilder: (context, anim1, anim2, child) {
                      return FadeTransition(
                        opacity: anim1.drive(
                          Tween(
                            begin: 0,
                            end: 1,
                          ),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                    barrierDismissible: true,
                  );
                  if (newTime != null) {
                    selectStartCallback(newTime);
                  }
                },
                child: Text(
                  '起始时间：${DateFormat('yyyy-MM-dd  HH:mm:ss').format(startTime)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 310,
            child: TextButton(
              onPressed: () async {
                DateTime? newTime = await showOmniDateTimePicker(
                  context: context,
                  initialDate: endTime,
                  firstDate:
                      DateTime(1600).subtract(const Duration(days: 3652)),
                  lastDate: DateTime.now().add(
                    const Duration(days: 3652),
                  ),
                  is24HourMode: true,
                  isShowSeconds: true,
                  minutesInterval: 1,
                  secondsInterval: 1,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  constraints: const BoxConstraints(
                    maxWidth: 350,
                    maxHeight: 650,
                  ),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return FadeTransition(
                      opacity: anim1.drive(
                        Tween(
                          begin: 0,
                          end: 1,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                  barrierDismissible: true,
                );
                if (newTime != null) {
                  selectEndCallback(newTime);
                }
              },
              child: Text(
                '结束时间：${DateFormat('yyyy-MM-dd  HH:mm:ss').format(endTime)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SizedBox(
              width: 310,
              child: ElevatedButton(
                onPressed: () {},
                child: const Row(
                  children: [
                     Icon(Icons.search),
                     Text(
                      '查询',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
