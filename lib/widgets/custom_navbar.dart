import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<String> icons;
  final List<String> labels;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              bool isActive = index == selectedIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                child: SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        transform: Matrix4.translationValues(
                          0,
                          isActive ? -18 : 0,
                          0,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.deepPurple
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Image.asset(
                              icons[index],
                              width: 24,
                              height: 24,
                              color: isActive
                                  ? Colors.white
                                  : Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isActive ? 1 : 0,
                        child: Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}