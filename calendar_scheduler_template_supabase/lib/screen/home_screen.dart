import 'package:calendar_scheduler/model/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar_scheduler/component/main_calendar.dart';
import 'package:calendar_scheduler/component/schedule_card.dart';
import 'package:calendar_scheduler/component/today_banner.dart';
import 'package:calendar_scheduler/component/schedule_bottom_sheet.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:provider/provider.dart'; // ➊ Provider 불러오기
import 'package:calendar_scheduler/provider/schedule_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
    // ➋ 선택된 날짜를 관리할 변수
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    final future = Supabase.instance.client.from('schedule').
    select().eq('date',
        '${selectedDate.year}${selectedDate.month.toString().padLeft(2,
            '0')}${selectedDate.day.toString().padLeft(2, '0')}');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // ➊ 새 일정 버튼
        backgroundColor: PRIMARY_COLOR,
        onPressed: () async {
          await showModalBottomSheet(
            // ➋ BottomSheet 열기
            context: context,
            isDismissible: true, // ➌ 배경 탭했을 때 BottomSheet 닫기
            isScrollControlled: true,
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate, // 선택된 날짜 (selectedDate) 넘겨주기
            ),
          );

          setState(() {

          });
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        // 시스템 UI 피해서 UI 구현하기
        child: Column(
          // 달력과 리스트를 세로로 배치
          children: [
            MainCalendar(
              selectedDate: selectedDate, // 선택된 날짜 전달하기

              // 날짜가 선택됐을 때 실행할 함수
              onDaySelected: (selectedDate, focusedDate) => onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),
            FutureBuilder<List<Map<String, dynamic>>>(
              // ListView에 적용했던 같은 쿼리
              future: future,
              builder: (context, snapshot) {
                return TodayBanner(
                  selectedDate: selectedDate,

                  // ➊ 개수 가져오기
                  count: snapshot.data?.length ?? 0,
                );
              },
            ),
            SizedBox(height: 8.0),
            Expanded(
              child:FutureBuilder<List<Map<String, dynamic>>>(
                // ➊ 파이어스토어로부터 일정 정보 받아오기
                future:future,
                builder: (context, snapshot) {
                  // Stream을 가져오는 동안 에러가 났을 때 보여줄 화면
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('일정 정보를 가져오지 못했습니다.'),
                    );
                  }

                  // 로딩 중일 때 보여줄 화면
                  if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                    return Container();
                  }

                  // ➋ ScheduleModel로 데이터 매핑하기
                  final schedules = snapshot.data!
                      .map(
                        (e) => ScheduleModel.fromJson(json: e),
                  )
                      .toList();

                  return ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];

                      return Dismissible(
                        key: ObjectKey(schedule.id),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (DismissDirection direction) async {
                          await Supabase.instance.client.from('schedule').
                          delete().match({
                            'id': schedule.id,
                          });
// 삭제 결과를 즉각 반영하기 위해 build() 함수를 실행합니다.
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                          child: ScheduleCard(
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            content: schedule.content,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime focusedDate,
      BuildContext context,
      ) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
