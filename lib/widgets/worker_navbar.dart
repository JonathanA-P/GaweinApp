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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? Colors.deepPurple : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: ImageIcon(
        AssetImage(asset),
        color: active ? Colors.white : Colors.grey,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: buildIcon('assets/images/Beranda.png', 0),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: buildIcon('assets/images/Loker.png', 1),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: buildIcon('assets/images/Kursus.png', 2),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: buildIcon('assets/images/Komunitas.png', 3),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: buildIcon('assets/images/Profil.png', 4),
          label: '',
        ),
      ],
    );
  }
}