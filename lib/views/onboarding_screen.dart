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
            image:
                'https://i.pinimg.com/736x/3b/53/b9/3b53b997556ce4993a7825ea0fa44fe9.jpg',
            colors: Colors.white,
          ),
          _Slide(
            title: 'Study Planner',
            desc: 'Organize your study schedule easily',
            image:
                'https://i.pinimg.com/736x/85/57/8a/85578a047e5cef40a2889aaf8df1b4b7.jpg',
            colors: Colors.white,
          ),
          _Slide(
            title: 'Community Q&A',
            desc: 'Ask questions and get answers',
            image:
                'https://i.pinimg.com/736x/37/a0/c6/37a0c608c8ab59345b79e10b8af6cfcb.jpg',
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
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
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
