import 'dart:async';
import 'dart:io';

import 'package:calendar_scheduler/model/schedule_model.dart';
import 'package:dio/dio.dart';

class ScheduleRepository {
  final _dio = Dio();
  final _targetUrl =
      'http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:3000/schedule'; // Android에서는 10.0.0.2가 localhost에 해당됩니다.

  Future<List<ScheduleModel>> getSchedules({
    required String accessToken,
    required DateTime date,
  }) async {
    final resp = await _dio.get(
      _targetUrl,
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
      queryParameters: {
        // ➊ Query Parameter
        'date':
            '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      },
    );

    return resp.data // ➋ 모델 인스턴스로 데이터 매핑하기
        .map<ScheduleModel>(
          (x) => ScheduleModel.fromJson(
            json: x,
          ),
        )
        .toList();
  }

  Future<String> createSchedule({
    required ScheduleModel schedule,
    required String accessToken,
  }) async {
    final json = schedule.toJson();

    final resp = await _dio.post(_targetUrl,
        data: json,
        options: Options(
          headers: {
            'authorization': 'Bearer $accessToken',
          },
        ));

    return resp.data?['id'];
  }

  Future<String> deleteSchedule({
    required String id,
    required String accessToken,
  }) async {
    final resp = await _dio.delete(_targetUrl,
        data: {
          'id': id, // 삭제할 ID값
        },
        options: Options(
          headers: {
            'authorization': 'Bearer $accessToken',
          },
        ));

    return resp.data?['id']; // 삭제된 ID값 반환
  }
}
