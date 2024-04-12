import 'package:flutter/material.dart';

class SecondAcreen extends StatefulWidget {
  const SecondAcreen({super.key});

  @override
  State<SecondAcreen> createState() => _SecondAcreenState();
}

class _SecondAcreenState extends State<SecondAcreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Scree'),
      ),
      body: const Column(
        children: [
          Text('Second Screen')
        ],
      ),
    );
  }
}
