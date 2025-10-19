import 'package:student_life_app/models/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_life_app/screens/clubs/event_details_screen.dart';

final Map<DateTime, List<Event>> mockEvents = {
  // Use UTC for consistency
  DateTime.utc(2025, 10, 19): [
    Event(
      title: 'Designing for Delight: Mastering UI/UX in the Digital Age',
      location: 'University Theatre 1',
      time: '10:00am to 1:00pm',
      bannerUrl: 'assets/images/designing_for_delight.jpeg',
      description:
          'In today\'s fast-paced digital world, creating visually appealing designs is no longer enough — users expect intuitive, seamless, and delightful experiences. "Designing for Delight: Mastering UI/UX in the Digital Age" is an inspiring and practical event that explores how thoughtful user interface (UI) and user experience (UX) design can elevate products and services to new levels of user satisfaction.\n\nWhat to Expect:\n• Keynote talks by experienced UI/UX professionals\n• Hands-on design challenges and live critiques\n• Tips on designing for accessibility, responsiveness, and engagement\n• Networking opportunities with fellow designers and developers',
      speakerInfo:
          'Ava Lim is a seasoned UX strategist and award-winning product designer with over 10 years of experience crafting intuitive digital experiences for global tech start-ups and Fortune 500 companies. Currently leading the design team at Nova Labs, Ava is passionate about bridging the gap between user empathy and business goals through meaningful design.',
      fee: 'Free',
    ),
    Event(
      title: 'Think Like a CEO: Strategy, Growth, and Leadership',
      location: 'Jeffery Cheah Hall 1',
      time: '3:00pm to 5:00pm',
      bannerUrl: 'assets/images/ceo.png',
      description:
          'This event offers valuable insights into strategic thinking, business growth, and effective leadership. Learn how to approach challenges with a CEO mindset, drive innovation, and lead your team to success. Ideal for aspiring entrepreneurs and future business leaders.',
      speakerInfo:
          'John Carter is a renowned business consultant and former CEO of a multinational corporation. With decades of experience, he provides actionable strategies for navigating the complexities of the modern business world.',
      fee: 'RM 50',
    ),
  ],
  DateTime.utc(2025, 10, 22): [
    Event(
      title: 'Photography Club Weekly Meetup',
      location: 'Student Hub, Level 3',
      time: '6:00pm to 8:00pm',
      bannerUrl: 'assets/images/photography_event_banner.png',
      description:
          'Join the Photography Club for our weekly meetup! This is a casual session for members to share their work, discuss techniques, and plan for upcoming photoshoots. All skill levels are welcome, from beginners to seasoned photographers.',
      speakerInfo:
          'This is a member-led session with no designated speaker. All attendees are encouraged to share and present their work.',
      fee: 'Free for members',
    ),
  ],
};

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<Event> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = _getEventsForDay(_selectedDay!);
  }

  // Helper method to get events for a specific day
  List<Event> _getEventsForDay(DateTime day) {
    // The key for the map must be in UTC format
    return mockEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
      _selectedEvents = _getEventsForDay(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- THE CALENDAR WIDGET ---
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
              // --- STYLING TO MATCH YOUR DESIGN ---
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // --- THE EVENT LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // This aligns the items
                children: [
                  Text(
                    "Today's Event", // You can still make this dynamic
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: _goToToday, // Call the method when pressed
                    child: const Text('Back to Today'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedEvents[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 12,
                      ),
                      title: Text(event.title),
                      subtitle: Text(event.location),
                      trailing: Text(event.time),

                      onTap: () {
                        // Navigate to the details screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Pass the current 'event' to the details screen
                            builder: (context) =>
                                EventDetailsScreen(event: event),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
