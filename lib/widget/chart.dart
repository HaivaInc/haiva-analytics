import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/colortheme.dart';

class ExampleChart extends StatefulWidget {
 final String? chartData;
  const ExampleChart({Key? key, required this.chartData}) : super(key: key);

  @override
  ExampleChartState createState() => ExampleChartState();
}

class ExampleChartState extends State<ExampleChart> {
  bool _isLoading = true;
  late String _chartData;
  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    try {
      setState(() {
        // _chartData = '''{
        //             "chart": {
        //             "type": "column"
        //             },
        //             "series": [
        //             {
        //                 "data": [
        //                 1834821.8,
        //                 950532.9,
        //                 741520.7
        //                 ],
        //                 "name": "Total Gross Sales"
        //             }
        //             ],
        //             "subtitle": "",
        //             "title": "",
        //             "xAxis": {
        //             "categories": [
        //                 "Choclates",
        //                 "Snacks",
        //                 "Juice"
        //             ]
        //             }
        //         }''';
        _isLoading = false;
        _chartData = widget.chartData!;
      });
    } catch (e) {
      print('Error fetching chart data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(
      //   child: _isLoading
      //       ?  SpinKitWave(color: ColorTheme.secondary)
      //       : HighCharts(
      //
      //     loader: const SizedBox(
      //       width: 200,
      //       child: SpinKitCubeGrid(color: Colors.blueAccent,),
      //     ),
      //     size:  Size(double.infinity, double.infinity),
      //     data: _chartData,
      //     scripts: const [
      //       "https://code.highcharts.com/highcharts.js",
      //       'https://code.highcharts.com/modules/networkgraph.js',
      //       'https://code.highcharts.com/modules/exporting.js',
      //     ],
      //   ),
      // ),
    );
  }
}
