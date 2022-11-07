// ignore_for_file: avoid_print

import './database_handler.dart';
import 'package:intl/intl.dart';

final DateFormat format = DateFormat('yyyy-MM-dd');

void numericAssessmentProcessor(
    List assessedResult, String? selectedDate, String? submissionDate) {
  if (assessedResult.isNotEmpty) {
    print('in here');
    // print(selectedDate.toString());

    var processedRecord = {};
    processedRecord['date'] = format.format(format.parse(selectedDate!));
    processedRecord['className'] = assessedResult[0]['className'];
    processedRecord['submissionDate'] = submissionDate;
    processedRecord['result'] = [];

    for (var i = 0; i < assessedResult.length; i++) {
      // print(record['result'] == '');
      if ((assessedResult[i]['result'] == '' ||
          assessedResult[i]['result'] == null)) {
        assessedResult[i]['result'] = 'Not Evaluated';
      }
      var a = {};
      a[assessedResult[i]['studentId']] = [
        assessedResult[i]['level'],
        assessedResult[i]['result']
      ];

      processedRecord['result'].add(a);
    }

    // print(processedRecord.toString());
    // print(processedRecord);

    DBProvider.db.saveNumericAssessment(processedRecord);
  }
}

Future<void> basicAssessmentProcessor(
    List assessedResult,
    String? selectedDate,
    String? selectedLanguage,
    String? submissionDate) async {
  if (assessedResult.isNotEmpty) {
    print('here');
    print(selectedDate.toString());
    print(selectedLanguage.toString());
    var processedRecord = {};
    processedRecord['date'] = format.format(format.parse(selectedDate!));

    processedRecord['language'] = selectedLanguage;
    processedRecord['className'] = assessedResult[0]['className'];
    processedRecord['submissionDate'] = submissionDate;
    processedRecord['result'] = [];

    for (var i = 0; i < assessedResult.length; i++) {
      if ((assessedResult[i]['result'] == '' ||
              assessedResult[i]['result'] == null) &&
          (assessedResult[i]['level'] == 0 ||
              assessedResult[i]['level'] == '0')) {
        assessedResult[i]['result'] = 'Not Evaluated';
      }

      var a = {};
      a[assessedResult[i]['studentId']] = [
        assessedResult[i]['level'],
        assessedResult[i]['result']
      ];

      processedRecord['result'].add(a);
    }
    // print(processedRecord.toString());
    // print(processedRecord);
    await DBProvider.db.saveReadingAssessment(processedRecord);
  }
}

void paceAssessmentProcessor(List studentList, String selectedDate,
    Map selectedAssesment, markSheet, result) {
  var processedRecord = {};
  processedRecord['assessmentName'] = selectedAssesment['name'];
  processedRecord['subjectName'] = selectedAssesment['subject_name'];
  processedRecord['medium_name'] = selectedAssesment['medium_name'];
  processedRecord['qp_code'] = selectedAssesment['qp_code'];
  processedRecord['qp_code_name'] = selectedAssesment['qp_code_name'];
  processedRecord['scheduledDate'] = selectedAssesment['date'];
  processedRecord['uploadDate'] =
      format.format(format.parse(selectedDate));

  processedRecord['className'] = studentList[0]['className'];

  if (markSheet.isEmpty && result.isEmpty) {
    for (var student in studentList) {
      markSheet[student['studentId']] = [0, 0, 0, 0, 0];
      result[student['studentId']] = 'Not Evaluated';
    }
  }
  if (markSheet.isNotEmpty && result.isNotEmpty) {
    for (var student in studentList) {
      if (markSheet[student['studentId']] == null) {
        markSheet[student['studentId']] = [0, 0, 0, 0, 0];
        result[student['studentId']] = 'Not Evaluated';
      }
    }
  }
  // print(markSheet.runtimeType);
  processedRecord['result'] = result;
  processedRecord['marksheet'] = markSheet;

  // print(processedRecord.toString());
  DBProvider.db.savePaceAssessment(processedRecord);
}
