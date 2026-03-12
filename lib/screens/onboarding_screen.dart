import 'package:flutter/material.dart';
import 'opening.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Cari Kerja",
      "desc":
          "Temukan Lowongan sesuai minat dan keahlian, lacak lamaran, dan dapatkan info terbaru",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Kursus",
      "desc":
          "Ikut kelas online / offline, tingkatkan skill dan raih sertifikat",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Komunitas",
      "desc":
          "Bergabung dengan komunitas sesuai minat, berbagi pengalaman, dan bangun relasi",
    },
  ];

  void _nextPage() {

    if (_currentPage == _onboardingData.length - 1) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OpeningScreen(),
        ),
      );

    } else {

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );

    }
  }

  void _previousPage() {

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );

  }

  void _skip() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OpeningScreen(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [

            /// Background shape ungu hanya untuk page ke-2
            if (_currentPage == 1)
              Positioned(
                right: -120,
                top: 120,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB39DDB),
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
              ),

            Column(
              children: [

                /// SKIP
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                /// PAGE VIEW
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,

                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },

                    itemBuilder: (context, index) {

                      final data = _onboardingData[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            /// IMAGE
                            Image.asset(
                              data["image"]!,
                              height: 260,
                            ),

                            const SizedBox(height: 40),

                            /// TITLE
                            Text(
                              data["title"]!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2A44),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// DESCRIPTION
                            Text(
                              data["desc"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// BOTTOM NAVIGATION
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// BACK
                      _currentPage == 0
                          ? const SizedBox(width: 40)
                          : IconButton(
                              onPressed: _previousPage,
                              icon: const Icon(Icons.arrow_back_ios),
                            ),

                      /// INDICATOR
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) {

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 10,
                              width: _currentPage == index ? 28 : 10,

                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF6C4AB6)
                                    : const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          },
                        ),
                      ),

                      /// NEXT
                      IconButton(
                        onPressed: _nextPage,
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}