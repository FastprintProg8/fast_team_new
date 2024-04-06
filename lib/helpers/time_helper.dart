class TimeHelper {

  String formatTime(String time) {
    // Assuming the input time format is "H:i:s"
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time; // Return the original value if it couldn't be formatted
  }
}