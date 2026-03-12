import 'package:flutter/material.dart';

class WorkerNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const WorkerNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  Widget buildIcon(String asset, int index) {
    bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, active ? -15 : 0, 0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? Colors.deepPurple : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: ImageIcon(
            AssetImage(asset),
            color: active ? Colors.white : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildIcon('assets/images/Beranda.png', 0),
          buildIcon('assets/images/Loker.png', 1),
          buildIcon('assets/images/Kursus.png', 2),
          buildIcon('assets/images/Komunitas.png', 3),
          buildIcon('assets/images/Profil.png', 4),
        ],
      ),
    );
  }
}