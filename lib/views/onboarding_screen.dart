import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../components/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _Slide(
            title: 'Offline Learning',
            desc: 'Download lessons and access them anytime',
            image:'assets/on1.jpg',
            colors: Colors.white,
          ),
          _Slide(
            title: 'Study Planner',
            desc: 'Organize your study schedule easily',
            image:'assets/on2.jpg',
            colors: Colors.white,
          ),
          _Slide(
            title: 'Community Q&A',
            desc: 'Ask questions and get answers',
            image:'assets/on3.jpg',
            colors: Colors.black,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          label: 'Get Started',
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.home),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String desc;
  final String image;
  final Color colors;

  const _Slide({
    required this.title,
    required this.desc,
    required this.image,
    required this.colors,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colors,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
