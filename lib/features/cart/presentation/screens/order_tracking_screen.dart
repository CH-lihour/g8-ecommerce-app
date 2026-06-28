import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../../data/order_service.dart';
import '../models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderLine line;

  const OrderTrackingScreen({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: const _FakeMap()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Order Tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        children: [
                          const _DragHandle(),
                          const SizedBox(height: 16),
                          const _CourierCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Progress of your Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProgressTimeline(line: line),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _MarkAsDoneButton(line: line),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FakeMap extends StatelessWidget {
  const _FakeMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8ECF1),
      child: CustomPaint(
        painter: _MapPainter(),
        child: Stack(
          children: const [
            // Origin marker (top-left area).
            Positioned(
              left: 70,
              top: 130,
              child: _MapPin(color: kPrimary, icon: Icons.circle, size: 14),
            ),
            // Destination marker (lower-middle).
            Positioned(
              left: 190,
              top: 250,
              child: _MapPin(
                color: kPrimary,
                icon: Icons.local_shipping,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.22),
        Offset(size.width, size.height * 0.30), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.45, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.62), road);

    final route = Paint()
      ..color = kPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(78, 142)
      ..lineTo(150, 142)
      ..lineTo(150, 262)
      ..lineTo(198, 262);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;

  const _MapPin({required this.color, required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: kDarkText),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alexander Jr',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Courier',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        _RoundIcon(icon: Icons.language),
        const SizedBox(width: 12),
        _RoundIcon(icon: Icons.call_outlined),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;

  const _RoundIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: kDarkText, size: 20),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  final OrderLine line;

  const _ProgressTimeline({required this.line});

  @override
  Widget build(BuildContext context) {
    final steps = <_ProgressStep>[
      _ProgressStep(
        title: line.product.name,
        subtitle: 'Shop',
        time: '02:50 PM',
        icon: Icons.storefront_outlined,
        active: true,
      ),
      const _ProgressStep(
        title: 'On the way',
        subtitle: 'Delivery',
        time: '03:20 PM',
        icon: Icons.pedal_bike,
        active: true,
      ),
      const _ProgressStep(
        title: '5482 Adobe Falls Rd #15 San Diego,...',
        subtitle: 'Houser',
        time: '03:45 PM',
        icon: Icons.location_on_outlined,
        active: false,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _ProgressStep {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool active;

  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.active,
  });
}

class _TimelineRow extends StatelessWidget {
  final _ProgressStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dotColor = step.active ? kPrimary : Colors.grey.shade300;
    final iconColor = step.active ? Colors.white : Colors.grey.shade500;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                child: Icon(step.icon, color: iconColor, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        step.subtitle,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        step.time,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkAsDoneButton extends StatelessWidget {
  final OrderLine line;

  const _MarkAsDoneButton({required this.line});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          OrderService.instance.markCompleted(line);
          Navigator.of(context).pop();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Mark as Done',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
