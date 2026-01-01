import 'package:flutter/material.dart';
 
class Ramadan extends StatefulWidget {
  const Ramadan({super.key});
 
  @override
  State<Ramadan> createState() => _RamadanState();
}
 
class _RamadanState extends State<Ramadan> {
  bool iftarReminder = true;
  bool showFullTimetable = false;
 
  int completedJuz = 0;
 
  final List<Map<String, String>> ramadanTimetable = List.generate(30, (index) {
    return {
      "day": "${index + 1}",
      "imsak": "4:${40 - index ~/ 3}".padLeft(5, '0'),
      "fajr": "4:${45 - index ~/ 3}".padLeft(5, '0'),
      "sunrise": "6:${10 + index ~/ 3}".padLeft(5, '0'),
      "dhuhr": "1:30 PM",
      "asr": "4:45 PM",
      "maghrib": "6:${5 + index ~/ 3} PM",
      "isha": "7:30 PM",
    };
  });
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: const Color(0xFF229B91),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
 
              /// IFTAR REMINDER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: const Color(0xFF229B91),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Iftar Reminder • 6:15 PM",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Switch(
                      value: iftarReminder,
                      onChanged: (v) {
                        setState(() => iftarReminder = v);
                      },
                      activeColor: Colors.white,
                    ),
                  ],
                ),
              ),
 
              const SizedBox(height: 24),
 
              /// RAMADAN ALERTS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Ramadan Alerts",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
 
              const SizedBox(height: 12),
 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _alertBox("Iftar Alert", "6:15 PM")),
                    const SizedBox(width: 12),
                    Expanded(child: _alertBox("Suhoor Alert", "4:30 AM")),
                  ],
                ),
              ),
 
              const SizedBox(height: 30),
 
              /// KHATMA SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Qur'an Khatma",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
 
              const SizedBox(height: 12),
 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF229B91),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Progress: $completedJuz / 30 Juz",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: completedJuz / 30,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: completedJuz < 30
                            ? () {
                                setState(() {
                                  completedJuz++;
                                });
                              }
                            : null,
                        child: Text(
                          completedJuz < 30
                              ? "Mark Today as Read"
                              : "Khatma Completed 🎉",
                          style: const TextStyle(
                              color: Color(0xFF229B91),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
 
              const SizedBox(height: 30),
 
              /// RAMADAN TIMETABLE TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Ramadan Timetable",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
 
              const SizedBox(height: 12),
 
              /// BUTTON TO SHOW / HIDE TIMETABLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229B91),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    setState(() {
                      showFullTimetable = !showFullTimetable;
                    });
                  },
                  child: Text(
                    showFullTimetable ? "Hide Full 30 Days" : "Show Full 30 Days",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
 
              if (showFullTimetable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    height: 300, // scrollable box height
                    decoration: BoxDecoration(
                      color: const Color(0xFF229B91),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _tableHeader(),
                          ...ramadanTimetable.map((day) => _tableRow(day)),
                        ],
                      ),
                    ),
                  ),
                ),
 
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
 
  static Widget _alertBox(String title, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF229B91),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.alarm, color: Colors.white),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(time, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
 
  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const [
          _HeaderCell("Day"),
          _HeaderCell("Imsak"),
          _HeaderCell("Fajr"),
          _HeaderCell("Sunrise"),
          _HeaderCell("Dhuhr"),
          _HeaderCell("Asr"),
          _HeaderCell("Maghrib"),
          _HeaderCell("Isha"),
        ],
      ),
    );
  }
 
  Widget _tableRow(Map<String, String> day) {
    bool lastTen = int.parse(day["day"]!) > 20; // last 10 days
    Color textColor = lastTen ? Colors.amber : Colors.white70;
 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _Cell(day["day"]!, textColor),
          _Cell(day["imsak"]!, textColor),
          _Cell(day["fajr"]!, textColor),
          _Cell(day["sunrise"]!, textColor),
          _Cell(day["dhuhr"]!, textColor),
          _Cell(day["asr"]!, textColor),
          _Cell(day["maghrib"]!, textColor),
          _Cell(day["isha"]!, textColor),
        ],
      ),
    );
  }
}
 
class _Cell extends StatelessWidget {
  final String text;
  final Color color;
  const _Cell(this.text, [this.color = Colors.white70]);
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
 
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
 
 