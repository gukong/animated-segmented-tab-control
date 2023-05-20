import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Provide the [TabController]
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SegmentedTabControl(
                    // Customization of widget
                    height: 60,
                    // Options for selection
                    // All specified values will override the [SegmentedTabControl] setting
                    textStyle: TextStyle(fontSize: 16, color: Colors.black87),
                    selectedTextStyle: TextStyle(fontSize: 20, color: Colors.deepOrange),
                    tabs: [
                      SegmentTab(
                        label: 'ACCOUNT',
                      ),
                      SegmentTab(
                        label: 'HOME',
                      ),
                      SegmentTab(label: 'NEW'),
                    ],
                  ),
                ),
                // Sample pages
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SampleWidget(
                        label: 'FIRST PAGE',
                        color: Colors.red.shade200,
                      ),
                      SampleWidget(
                        label: 'SECOND PAGE',
                        color: Colors.blue.shade100,
                      ),
                      SampleWidget(
                        label: 'THIRD PAGE',
                        color: Colors.orange.shade200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SampleWidget extends StatelessWidget {
  const SampleWidget({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
      child: ListView.builder(
        itemCount: 100,
        itemExtent: 30,
        itemBuilder: (BuildContext context, int index) {
          return Text(index.toString());
        },
      ),
    );
  }
}
