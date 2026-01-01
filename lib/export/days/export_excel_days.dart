// lib/export/days/export_excel_days.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../firebase/firestore/movements_days.dart';
import '../../firebase/firestore/products_firestore.dart';
import '../styles/excel_styles.dart';

class ExportExcelDays {
  static const double columnWidth = 20;

  static Future<File> export({
    required List<DateTime> days,
    required String uid,
    required List<Movement> movements,
  }) async {
    try {
      if (days.isEmpty) {
        throw Exception('Nenhuma data selecionada.');
      }

      days.sort((a, b) => a.compareTo(b));
      final companyName = await _getCompanyName(uid);

      final products = await ProductsFirestore.streamProducts(uid).first;
      final productMap = {for (var p in products) p.id: p};

      final excel = Excel.createExcel();

      /* ================== CAPA ================== */
      final capa = excel['Capa do Relatório'];

      for (var i = 0; i < 6; i++) {
        capa.setColumnWidth(i, 30);
      }

      _applyBrandHeader(capa, 6, companyName);

      capa.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('F3'));
      capa.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'RELATÓRIO DE MOVIMENTAÇÕES',
      );
      capa.cell(CellIndex.indexByString('A3')).cellStyle =
          ExcelStyles.sheetTitle;

      capa.merge(CellIndex.indexByString('A5'), CellIndex.indexByString('F5'));
      capa.cell(CellIndex.indexByString('A5')).value = TextCellValue(
        'Período: ${DateFormat('dd/MM/yyyy').format(days.first)} até ${DateFormat('dd/MM/yyyy').format(days.last)}',
      );
      capa.cell(CellIndex.indexByString('A5')).cellStyle =
          ExcelStyles.centerNoBorder;

      capa.merge(CellIndex.indexByString('A6'), CellIndex.indexByString('F6'));
      capa.cell(CellIndex.indexByString('A6')).value = TextCellValue(
        'Exportado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      );
      capa.cell(CellIndex.indexByString('A6')).cellStyle =
          ExcelStyles.centerNoBorder;

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      /* ================== RESUMO GERAL ================== */
      final summary = excel['Resumo Geral'];
      _setColumnWidths(summary, 4);
      _applyBrandHeader(summary, 4, companyName);

      summary.merge(
        CellIndex.indexByString('A3'),
        CellIndex.indexByString('D3'),
      );
      summary.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'Relatório Consolidado',
      );
      summary.cell(CellIndex.indexByString('A3')).cellStyle =
          ExcelStyles.resumoGeralTitle;

      summary.appendRow([
        TextCellValue('Data'),
        TextCellValue('Entradas'),
        TextCellValue('Saídas'),
        TextCellValue('Saldo'),
      ]);

      for (var col = 0; col < 4; col++) {
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3))
                .cellStyle =
            ExcelStyles.header;
      }

      int totalAdd = 0;
      int totalRemove = 0;

      for (final day in days) {
        final dayMovements = movements.where(
          (m) =>
              m.timestamp.year == day.year &&
              m.timestamp.month == day.month &&
              m.timestamp.day == day.day,
        );

        final add = dayMovements
            .where((m) => m.type == 'add')
            .fold<int>(0, (s, m) => s + m.quantity);

        final remove = dayMovements
            .where((m) => m.type == 'remove')
            .fold<int>(0, (s, m) => s + m.quantity);

        totalAdd += add;
        totalRemove += remove;

        summary.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy').format(day)),
          IntCellValue(add),
          IntCellValue(remove),
          IntCellValue(add - remove),
        ]);

        for (var col = 1; col < 4; col++) {
          summary
                  .cell(
                    CellIndex.indexByColumnRow(
                      columnIndex: col,
                      rowIndex: summary.maxRows - 1,
                    ),
                  )
                  .cellStyle =
              ExcelStyles.dataCenterSmall;
        }
      }

      summary.appendRow([]);
      summary.appendRow([
        TextCellValue('Totais Gerais'),
        IntCellValue(totalAdd),
        IntCellValue(totalRemove),
        IntCellValue(totalAdd - totalRemove),
      ]);

      final totalRow = summary.maxRows - 1;
      for (var col = 0; col < 4; col++) {
        summary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: totalRow),
            )
            .cellStyle = ExcelStyles
            .total;
      }
      // ================== DISTRIBUIÇÃO PERCENTUAL (APENAS ENTRADAS) ==================

      // linha em branco para respiro visual
      summary.appendRow([TextCellValue('')]);

      // ===== TÍTULO =====
      summary.appendRow([
        TextCellValue('Distribuição Percentual por Produto (Entradas)'),
      ]);

      final distTitleRow = summary.maxRows - 1;

      // merge do título (A até D)
      summary.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: distTitleRow),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: distTitleRow),
      );

      // estilo do título
      summary
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: distTitleRow),
          )
          .cellStyle = ExcelStyles
          .resumoGeralTitle;

      // ===== CABEÇALHO =====
      summary.appendRow([
        TextCellValue('Produto'),
        TextCellValue('Categoria'),
        TextCellValue('Quantidade de Entrada'),
        TextCellValue('Percentual'),
      ]);

      final headerRow = summary.maxRows - 1;

      for (var col = 0; col < 4; col++) {
        summary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRow),
            )
            .cellStyle = ExcelStyles
            .header;
      }

      // 🔹 TOTAL DE ENTRADAS POR PRODUTO
      final Map<String, int> productEntradaTotals = {};

      for (final m in movements) {
        if (m.type != 'add') continue;

        productEntradaTotals.update(
          m.productName,
          (value) => value + m.quantity,
          ifAbsent: () => m.quantity,
        );
      }

      // 🔹 TOTAL GERAL DE ENTRADAS
      final int totalEntradas = productEntradaTotals.values.fold(
        0,
        (a, b) => a + b,
      );

      // 🔹 DADOS
      productEntradaTotals.forEach((productName, quantity) {
        final double percent = totalEntradas == 0
            ? 0
            : quantity / totalEntradas;

        // 🔎 tenta localizar o produto no productMap (SEM classe Product)
        dynamic product;

        for (final p in productMap.values) {
          if (p.name == productName) {
            product = p;
            break;
          }
        }

        summary.appendRow([
          TextCellValue(productName),
          TextCellValue(product?.category ?? '-'),
          IntCellValue(quantity),
          DoubleCellValue(percent),
        ]);

        final row = summary.maxRows - 1;

        // Produto
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
                .cellStyle =
            ExcelStyles.dataCenterSmall;

        // Categoria
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
                .cellStyle =
            ExcelStyles.dataCenterSmall;

        // Quantidade
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
                .cellStyle =
            ExcelStyles.dataCenterSmall;

        // Percentual (%)
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
                .cellStyle =
            ExcelStyles.percent;
      });

      /* ================== ABAS POR DIA ================== */
      for (final day in days) {
        final sheet = excel[DateFormat('dd-MM-yyyy').format(day)];
        _setColumnWidths(sheet, 10);
        _applyBrandHeader(sheet, 10, companyName);

        sheet.merge(
          CellIndex.indexByString('A3'),
          CellIndex.indexByString('J3'),
        );
        sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
          'Relatório Diário — ${DateFormat('dd/MM/yyyy').format(day)}',
        );
        sheet.cell(CellIndex.indexByString('A3')).cellStyle =
            ExcelStyles.sheetTitle;

        /* ===== HEADER ===== */
        sheet.appendRow([
          TextCellValue('Horário'),
          TextCellValue('Nome do Produto'),
          TextCellValue('Tipo'),
          TextCellValue('Movimentações'),
          TextCellValue('Código de Barras'),
          TextCellValue('Categoria'),
          TextCellValue('Custo Médio'),
          TextCellValue('Preço Unitário'),
          TextCellValue('Estoque Atual'),
          TextCellValue('Estoque Mínimo'),
        ]);

        for (var col = 0; col < 10; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 4))
              .cellStyle = ExcelStyles
              .header;
        }

        final dayMovements =
            movements
                .where(
                  (m) =>
                      m.timestamp.year == day.year &&
                      m.timestamp.month == day.month &&
                      m.timestamp.day == day.day,
                )
                .toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        int addDay = 0;
        int removeDay = 0;
        double totalCostDay = 0;

        for (final m in dayMovements) {
          final product = productMap[m.productId];
          final cost = product?.cost ?? 0;

          if (m.type == 'add') addDay += m.quantity;
          if (m.type == 'remove') removeDay += m.quantity;

          totalCostDay += cost * m.quantity;

          sheet.appendRow([
            TextCellValue(DateFormat('HH:mm').format(m.timestamp)),
            TextCellValue(m.productName),
            TextCellValue(m.type == 'add' ? 'Entrada' : 'Saída'),
            IntCellValue(m.quantity),
            TextCellValue(product?.barcode ?? ''),
            TextCellValue(product?.category ?? ''),
            TextCellValue(
              'R\$ ${cost.toStringAsFixed(2).replaceAll('.', ',')}',
            ),
            TextCellValue(
              'R\$ ${(product?.unitPrice ?? 0).toStringAsFixed(2).replaceAll('.', ',')}',
            ),
            IntCellValue(product?.quantity ?? 0),
            IntCellValue(product?.minStock ?? 0),
          ]);

          final row = sheet.maxRows - 1;

          // define o estilo da linha conforme o tipo
          final CellStyle rowStyle = m.type == 'add'
              ? ExcelStyles.colorEntrada
              : ExcelStyles.colorSaida;

          // aplica o estilo da coluna A até J
          for (var col = 0; col < 10; col++) {
            sheet
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: col,
                        rowIndex: row,
                      ),
                    )
                    .cellStyle =
                rowStyle;
          }
        }

        /* ===== RESUMO ===== */
        sheet.appendRow([TextCellValue('')]);
        sheet.appendRow([TextCellValue('Valor Total Custo')]);

        final resumoRow = sheet.maxRows - 1;
        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: resumoRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: resumoRow),
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: resumoRow),
            )
            .cellStyle = ExcelStyles
            .summaryTitle;

        sheet.appendRow([TextCellValue('Entradas'), IntCellValue(addDay)]);
        sheet.appendRow([TextCellValue('Saídas'), IntCellValue(removeDay)]);
        sheet.appendRow([
          TextCellValue('Saldo'),
          IntCellValue(addDay - removeDay),
        ]);
        sheet.appendRow([
          TextCellValue('Custo Total'),
          DoubleCellValue(totalCostDay),
        ]);

        final custoRow = sheet.maxRows - 1;

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: custoRow),
            )
            .cellStyle = ExcelStyles
            .total;

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: custoRow),
            )
            .cellStyle = ExcelStyles.total
          ..numberFormat = NumFormat.custom(formatCode: r'"R$" #,##0.00');

        for (var i = 1; i <= 3; i++) {
          // coluna A
          sheet
                  .cell(
                    CellIndex.indexByColumnRow(
                      columnIndex: 0,
                      rowIndex: resumoRow + i,
                    ),
                  )
                  .cellStyle =
              ExcelStyles.dataCenterSmall;

          // coluna B
          sheet
                  .cell(
                    CellIndex.indexByColumnRow(
                      columnIndex: 1,
                      rowIndex: resumoRow + i,
                    ),
                  )
                  .cellStyle =
              ExcelStyles.dataCenterSmall;
        }
      }

      final bytes = excel.encode();
      final dir = await getApplicationDocumentsDirectory();

      final date = DateFormat('dd-MM-yy').format(days.first);
      final safeCompanyName = companyName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '',
      );

      final file = File(
        '${dir.path}/MyStoreDay - Relatórios Diários de $safeCompanyName em $date.xlsx',
      );

      await file.writeAsBytes(bytes!);
      return file;
    } catch (e) {
      throw Exception('Erro ao exportar Excel: $e');
    }
  }

  /* ================== HELPERS ================== */

  static void _setColumnWidths(Sheet sheet, int columns) {
    for (var i = 0; i < columns; i++) {
      double width = columnWidth;
      if (i == 0) width = 14;
      if (i == 1) width = 32;
      if (i == 4 || i == 5) width = 22;
      sheet.setColumnWidth(i, width);
    }
  }

  static void _applyBrandHeader(Sheet sheet, int columns, String companyName) {
    final endColumn = String.fromCharCode(65 + columns - 1);

    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('${endColumn}1'),
    );

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'MyStoreDay | ${companyName.toUpperCase()}',
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle =
        ExcelStyles.coverTitle;
    sheet.setRowHeight(0, 30);
  }

  static Future<String> _getCompanyName(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['company'] ?? 'MyStoreDay';
    } catch (_) {
      return 'MyStoreDay';
    }
  }
}
