import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../theme/colortheme.dart';
import 'dart:convert';

class TableData extends StatefulWidget {
  final dynamic tableData;
  const TableData({Key? key, required this.tableData}) : super(key: key);

  @override
  TableDataState createState() => TableDataState();
}

class TableDataState extends State<TableData> {
  bool isLoading = true;
  List<Map<String, dynamic>> tableData = [];
  TableDataSource? dataSource;

  @override
  void initState() {
    super.initState();
    processTableData();
  }

  void processTableData() {
    try {
      dynamic data = widget.tableData;
      if (data is String) {
        data = json.decode(data);
      }
      if (data is List && data.isNotEmpty) {
        if (data[0] is Map<String, dynamic>) {
          tableData = List<Map<String, dynamic>>.from(data);
        } else {
          throw FormatException('Unexpected data format');
        }
      } else {
        throw FormatException('Data is not a non-empty list');
      }
      if (tableData.isNotEmpty) {
        dataSource = TableDataSource(tableData: tableData);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error processing table data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: isLoading
            ? SpinKitCubeGrid(
          color: Colors.blue, // Loading spinner color
        )
            : dataSource != null
            ? Container(

          margin: EdgeInsets.all(16),
          child: SfDataGrid(

            source: dataSource!,
            columns: getColumns(),
            gridLinesVisibility: GridLinesVisibility.both,

            headerGridLinesVisibility: GridLinesVisibility.both,
            selectionMode: SelectionMode.single,
            allowColumnsResizing: true,
            allowColumnsDragging: true,
            allowExpandCollapseGroup: true,
            navigationMode: GridNavigationMode.cell,

            allowMultiColumnSorting: true,
            allowTriStateSorting: true,
            columnWidthMode: ColumnWidthMode.fill,
            frozenColumnsCount: 1,
          ),
        )
            : Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: Text(
              'No data available',
              style:GoogleFonts.questrial(
                color: Colors.red, // Text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<GridColumn> getColumns() {
    if (tableData.isEmpty) return [];
    return tableData[0].keys.map((key) {
      return GridColumn(
        columnName: key,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,

          child: Text(
            key,
            style: GoogleFonts.questrial(

              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class TableDataSource extends DataGridSource {
  TableDataSource({required List<Map<String, dynamic>> tableData}) {
    _tableData = tableData
        .map((data) => DataGridRow(
      cells: data.entries
          .map((e) => DataGridCell<dynamic>(
        columnName: e.key,
        value: e.value,
      ))
          .toList(),
    ))
        .toList();
  }

  List<DataGridRow> _tableData = [];

  @override
  List<DataGridRow> get rows => _tableData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(
            e.value.toString(),
            style: GoogleFonts.questrial(

            ), // Cell text color
          ),
        );
      }).toList(),
    );
  }
}
