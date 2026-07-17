import 'dart:math';

class IssueIdService {
  const IssueIdService();

  String generate({DateTime? now}) {
    final DateTime ts = (now ?? DateTime.now()).toUtc();
    final String y = ts.year.toString();
    final String m = ts.month.toString().padLeft(2, '0');
    final String d = ts.day.toString().padLeft(2, '0');
    final int randomPart = 100000 + Random.secure().nextInt(900000);
    final int micros = ts.microsecondsSinceEpoch % 100000;
    return 'ML-$y$m$d-$randomPart$micros';
  }
}
