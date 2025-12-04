import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:student_life_app/screens/clubs/event_details_screen.dart';
import 'package:student_life_app/models/event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // This Map replaces your hardcoded 'mockEvents'
  Map<DateTime, List<Event>> _events = {};

  late List<Event> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = [];
    _fetchEvents(); // Fetch data when screen loads
  }

  // --- NEW: Fetch from Firestore ---
  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      Map<DateTime, List<Event>> tempEvents = {};

      for (var doc in snapshot.docs) {
        final event = Event.fromFirestore(doc.data());

        // We must normalize the date to UTC Midnight for the Calendar to recognize it
        final dateKey = DateTime.utc(
          event.date.year,
          event.date.month,
          event.date.day,
        );

        if (tempEvents[dateKey] == null) {
          tempEvents[dateKey] = [];
        }
        tempEvents[dateKey]!.add(event);
      }

      setState(() {
        _events = tempEvents;
        _isLoading = false;
        // Update selected events in case the current day has events
        _selectedEvents = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() => _isLoading = false);
    }
  }

  // Helper method to get events for a specific day
  List<Event> _getEventsForDay(DateTime day) {
    // The key for the map must be in UTC format
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
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

  Color _getMarkerColor(Event event) {
    final now = DateTime.now();

    // IMPORTANT: This requires your Event model to have the 'startDateTime' helper.
    // If you haven't updated your Event model yet, use the 'Fallback' logic below.

    // Try to parse the time from the string "10:00am"
    try {
      // 1. Clean the string to get just the start time (e.g. "10:00am")
      final startTimeString = event.time.split(' to ')[0].trim();

      // 2. Parse "10:00am"
      // Note: You might need to import 'package:intl/intl.dart';
      // If you don't want to use intl, we can do a simpler check based on date only.

      // --- SIMPLIFIED LOGIC (Safest if you didn't update Event Model) ---
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      final today = DateTime(now.year, now.month, now.day);

      if (eventDate.isBefore(today)) {
        return Colors.red; // Past Date
      } else if (eventDate.isAfter(today)) {
        return const Color(0xFF0D47A1); // Future Date
      } else {
        return Colors.green; // Today (Ongoing)
      }
      // ------------------------------------------------------------------
    } catch (e) {
      return Colors.grey; // Fallback color if something breaks
    }
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

              // --- STYLING ---
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
                // REMOVED: markerDecoration (We don't want static black dots anymore)
              ),

              // --- NEW: THIS IS WHERE THE MAGIC HAPPENS ---
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  // 1. SAFETY CHECK: If no events, return nothing immediately.
                  if (events.isEmpty) return const SizedBox();

                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(4).map((e) {
                        // 2. OPTIONAL: Limit to max 4 dots
                        final event = e as Event;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getMarkerColor(event),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16.0),

            // --- THE HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Events", style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: _goToToday,
                    child: const Text('Back to Today'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8.0),

            // --- THE EVENT LIST ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedEvents.isEmpty
                  ? const Center(child: Text("No events for this day."))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedEvents[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Icon(
                              Icons.circle,
                              // This already worked, but now it matches the calendar!
                              color: _getMarkerColor(event),
                              size: 12,
                            ),
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: TextStyle(color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Text(
                              event.time,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
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
