import 'package:flutter/material.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';

void main() {
  runApp(MaterialApp(
    home: History(),
  ));
}

class History extends StatelessWidget {
  final List<Milestone> milestones = [
    Milestone(
        label: 'TTD Kontrak', date: 'Jan 2023', description: 'Kontrak Training'),
    Milestone(
        label: 'TTD Kontrak', date: 'Mar 2023', description: 'Kontrak Junior'),
    Milestone(
        label: 'Kenaikan Gaji', date: 'May 2023', description: 'Dari 2.000.000 menjadi 10.000.000'),
    Milestone(
        label: 'Punishment', date: 'Aug 2023', description: 'SP 1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milestone History'),
      ),
      body: TimelineView(milestones: milestones),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTabTapped: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamed('/home');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/profile');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/request');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/inbox');
          }
        },
      ),
    );
  }
}

class Milestone {
  final String label;
  final String date;
  final String description;

  Milestone({
    required this.label,
    required this.date,
    required this.description,
  });
}

class TimelineView extends StatelessWidget {
  final List<Milestone> milestones;

  TimelineView({required this.milestones});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: TimelinePainter(milestones: milestones),
      child: ListView.builder(
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          return MilestoneCard(
              milestone: milestones[index], isEven: index.isEven);
        },
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final List<Milestone> milestones;

  TimelinePainter({required this.milestones});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < milestones.length; i++) {
      final centerX = 24.0;
      final centerY = i * 100.0 + 80.0; // 80.0 adalah tengah dari lingkaran

      if (i < milestones.length - 1) {
        final nextCenterY = (i + 1) * 109.0 + 80.0;
        canvas.drawLine(
            Offset(centerX, centerY), Offset(centerX, nextCenterY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final bool isEven;

  MilestoneCard({
    required this.milestone,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleIndicator(),
          SizedBox(width: 16),
          Expanded(child: MilestoneDetails(milestone: milestone)),
        ],
      ),
    );
  }
}

class CircleIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
    );
  }
}

class MilestoneDetails extends StatelessWidget {
  final Milestone milestone;

  MilestoneDetails({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(milestone.date),
            SizedBox(height: 8),
            Text(milestone.description),
          ],
        ),
      ),
    );
  }
}
