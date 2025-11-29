import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays < 0) {
      return 'Overdue by ${(-difference.inDays)} days';
    } else if (difference.inDays == 0) {
      if (difference.inHours < 0) {
        return 'Overdue by ${(-difference.inHours)} hours';
      } else if (difference.inHours < 1) {
        return 'Due in ${difference.inMinutes} minutes';
      } else {
        return 'Due in ${difference.inHours} hours';
      }
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else {
      return DateFormat('MMM dd, yyyy').format(deadline);
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

