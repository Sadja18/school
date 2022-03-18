dynamic paceSubmitValidation(studentList, markSheet, resultSheet) {
  if (studentList.isEmpty) {
    return {"0": "Empty Student Info"};
  } else {
    if (markSheet.isNotEmpty && resultSheet.isNotEmpty) {
      return {"0": "Okay"};
    } else {
      if (markSheet.isEmpty) {
        return {"0": "Empty marksheet"};
      } else if (resultSheet.isEmpty) {
        return {"0": "Empty  result sheet"};
      }
    }
  }
}
