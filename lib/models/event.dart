class Event {
  final String title;
  final String location;
  final String time;
  final String bannerUrl;
  final String description;
  final String speakerInfo; // <-- Add this
  final String fee; // <-- Add this
  // Add any other fields you need, like dress code, etc.

  Event({
    required this.title,
    required this.location,
    required this.time,
    required this.bannerUrl,
    required this.description,
    required this.speakerInfo,
    required this.fee,
  });
}
