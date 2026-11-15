import 'package:intl/intl.dart';

class Formatters {
  static String compact(int number) {
    if (number >= 1000000000) {
      double n = number / 1000000000;
      return '${n.toStringAsFixed(n >= 10 ? 0 : 1)}B';
    } else if (number >= 1000000) {
      double n = number / 1000000;
      return '${n.toStringAsFixed(n >= 10 ? 0 : 1)}M';
    } else if (number >= 1000) {
      double n = number / 1000;
      return '${n.toStringAsFixed(n >= 10 ? 0 : 1)}K';
    }
    return number.toString();
  }

  static String withCommas(int number) {
    return NumberFormat('#,###').format(number);
  }

  static String percentage(double val) {
    return '${val.toStringAsFixed(1)}%';
  }

  static String deltaPercentage(num original, num edited) {
    if (original == 0) return '+0%';
    double delta = ((edited - original) / original) * 100;
    String sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)}%';
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}
