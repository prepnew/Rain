import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rain/app/data/weather.dart';
import 'package:rain/app/modules/home.dart';
import 'package:rain/app/widgets/button.dart';
import 'package:rain/main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/weather.png',
                    scale: 7,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Rain - ${'name'.tr}',
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 300,
                    child: Text(
                      'description'.tr,
                      style: context.theme.textTheme.labelMedium
                          ?.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: MyTextButton(
                buttonName: 'start'.tr,
                onTap: () async {
                  settings.onboard = true;
                  isar.writeTxn(() async => isar.settings.put(settings));
                  Get.off(
                    () => const HomePage(),
                    transition: Transition.downToUp,
                  );
                },
                bgColor: context.theme.colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
