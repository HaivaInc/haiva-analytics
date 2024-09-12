import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeployInfoPage extends StatefulWidget {
  final String agent;

  const DeployInfoPage({Key? key, required this.agent}) : super(key: key);

  @override
  State<DeployInfoPage> createState() => _DeployInfoPageState();
}

class _DeployInfoPageState extends State<DeployInfoPage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Deploy Info'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 20),
                _buildSegmentedControl(),
                SizedBox(height: 20),
                _buildSelectedContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSegmentedControl() {
    return CupertinoSegmentedControl<int>(

      children: {
        0: Padding(
          padding: EdgeInsets.all(8),
          child: Text('Web Tagging'),
        ),
        1: Padding(
          padding: EdgeInsets.all(8),
          child: Text('Android'),
        ),
      },
      onValueChanged: (int value) {
        setState(() {
          _selectedSegment = value;
        });
      },
      groupValue: _selectedSegment,
    );
  }

  Widget _buildSelectedContent() {
    if (_selectedSegment == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Web Tagging Script',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Copy the HTML code provided below and insert it immediately before the closing </body> tag on each page where you want the chat widget to be displayed.' ,style: TextStyle(fontSize: 12, ),),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              '<script src="https://agent.haiva.ai/js/script.js" '
                  'data-agent-id="${widget.agent}"></script>',
              style: TextStyle(color: CupertinoColors.activeGreen, fontFamily: 'Courier', fontSize: 12),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Android Integration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Android integration comming soon on mobile version ',   style: TextStyle(fontSize: 16),
          ),
        ],
      );
    }
  }
}
