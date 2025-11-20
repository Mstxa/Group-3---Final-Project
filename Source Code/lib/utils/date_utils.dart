import 'package:intl/intl.dart';

String fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String fmtHuman(DateTime d) => DateFormat('EEE, d MMM').format(d);
