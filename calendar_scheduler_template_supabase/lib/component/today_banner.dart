import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDate; // ➊ 선택된 날짜
  final int count; // ➋ 일정 개수

  const TodayBanner({
    required this.selectedDate,
    required this.count,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      // 기본으로 사용할 글꼴
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일', // “년 월 일” 형태로 표시
                style: textStyle,
              ),
            ),
            Text(
              '$count개', // 일정 개수 표시
              style: textStyle,
            ),
            const SizedBox(width: 8.0),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
              ],
            ),
// 슈파베이스의 signOut() 함수를 실행하면 로그아웃할
          ],
        ),
      ),
    );
  }
}
