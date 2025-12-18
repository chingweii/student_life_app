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

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      Map<DateTime, List<Event>> tempEvents = {};

      for (var doc in snapshot.docs) {
        // --- CRITICAL FIX HERE ---
        // We now pass both the data AND the document ID (doc.id)
        final event = Event.fromFirestore(doc.data(), doc.id);

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
        if (_selectedDay != null) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
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

    // 1. Create a clean Date object for "Today" (midnight)
    final todayDate = DateTime(now.year, now.month, now.day);

    // 2. Create a clean Date object for the Event
    final eventDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    // --- CHECK 1: DIFFERENT DAYS ---
    if (eventDate.isBefore(todayDate)) {
      return Colors.red; // Past Day
    } else if (eventDate.isAfter(todayDate)) {
      return const Color(0xFF0D47A1); // Future Day (Blue)
    }

    // --- CHECK 2: SAME DAY (TIME SENSITIVE) ---
    // If we are here, it means the event is TODAY.
    // We must parse the string "5:00pm to 7:00pm" to compare times.

    try {
      // Split "5:00pm to 7:00pm" into ["5:00pm", "7:00pm"]
      final timeParts = event.time.split(' to ');
      final startStr = timeParts[0].trim(); // "5:00pm"

      // If there is an end time, use it. Otherwise, assume event is 1 hour long.
      final endStr = timeParts.length > 1 ? timeParts[1].trim() : null;

      // Parse Start Time
      final startTime = _parseDateTime(startStr, eventDate);

      // Parse End Time (or fallback to start + 1 hour)
      final endTime = endStr != null
          ? _parseDateTime(endStr, eventDate)
          : startTime.add(const Duration(hours: 1));

      // --- THE LOGIC YOU REQUESTED ---
      if (now.isBefore(startTime)) {
        // Example: Now 4:55pm, Start 5:00pm
        return const Color(0xFF0D47A1); // Blue (Upcoming today)
      } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
        // Example: Now 5:31pm, Start 5:00pm, End 7:00pm
        return Colors.green; // Green (Happening NOW)
      } else {
        // Example: Now 7:01pm
        return Colors.red; // Red (Finished today)
      }
    } catch (e) {
      // Fallback if parsing fails (e.g. format is wrong)
      return Colors.grey;
    }
  }

  // --- HELPER FUNCTION TO PARSE "5:00pm" ---
  DateTime _parseDateTime(String timeStr, DateTime originalDate) {
    // 1. Remove "am" or "pm" to get numbers
    final isPm = timeStr.toLowerCase().contains('pm');
    final cleanTime = timeStr
        .toLowerCase()
        .replaceAll(RegExp(r'[a-z]'), '')
        .trim();

    // 2. Split "5:00" into [5, 0]
    final parts = cleanTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // 3. Convert to 24-hour format
    if (isPm && hour != 12) {
      hour += 12; // 5pm -> 17
    } else if (!isPm && hour == 12) {
      hour = 0; // 12am -> 0
    }

    // 4. Combine with the event date
    return DateTime(
      originalDate.year,
      originalDate.month,
      originalDate.day,
      hour,
      minute,
    );
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
