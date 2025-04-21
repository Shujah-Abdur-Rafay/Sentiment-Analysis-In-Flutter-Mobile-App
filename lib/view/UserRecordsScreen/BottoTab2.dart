import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/view/TabsScreen/AllAudios.dart';
import 'package:vocal_emotion/view/TabsScreen/historytab.dart';
import 'package:vocal_emotion/widgets/CustomTab.dart';

class EveryThings extends StatefulWidget {
  const EveryThings({super.key});

  @override
  State<EveryThings> createState() => _EveryThingsState();
}

class _EveryThingsState extends State<EveryThings> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode
            ? AppColors.darkblack
            : AppColors.homescreen,
        appBar: AppBar(
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              CustomTab(icon: Icons.play_arrow, label: 'Current Status'),
              CustomTab(icon: Icons.audiotrack, label: 'All Audios'),
              CustomTab(icon: Icons.history, label: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrentStatusTab(),
            AllAudioTab(),
            HistoryTab(),
          ],
        ),
      ),
    );
  }
}

class CurrentStatusTab extends StatelessWidget {
  const CurrentStatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Current Status Content'),
    );
  }
}
