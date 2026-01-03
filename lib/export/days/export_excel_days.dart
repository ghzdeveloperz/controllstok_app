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
      _setColumnWidths(summary, 6);
      _applyBrandHeader(summary, 6, companyName);

      summary.merge(
        CellIndex.indexByString('A3'),
        CellIndex.indexByString('F3'),
      );
      summary.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'Relatório Consolidado',
      );
      summary.cell(CellIndex.indexByString('A3')).cellStyle =
          ExcelStyles.resumoGeralTitle;

      summary.appendRow([
        TextCellValue('Data'),
        TextCellValue('Entradas (Qtd)'),
        TextCellValue('Saídas (Qtd)'),
        TextCellValue('Saldo (Qtd)'),
        TextCellValue('Custo Médio'),
        TextCellValue('Saldo Financeiro'),
      ]);

      for (var col = 0; col < 6; col++) {
        summary
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3))
                .cellStyle =
            ExcelStyles.header;
      }

      /// ================== ACUMULADORES GLOBAIS ==================
      int saldoQuantidade = 0;
      double saldoFinanceiro = 0.0;
      double custoMedio = 0.0;

      for (final day in days) {
        final dayMovements = movements.where(
          (m) =>
              m.timestamp.year == day.year &&
              m.timestamp.month == day.month &&
              m.timestamp.day == day.day,
        );

        int entradasQtd = 0;
        int saidasQtd = 0;
        double entradasValor = 0.0;
        double saidasValor = 0.0;

        for (final m in dayMovements) {
          if (m.type == 'add') {
            entradasQtd += m.quantity;
            entradasValor += m.quantity * m.unitPrice;
          } else if (m.type == 'remove') {
            saidasQtd += m.quantity;
            saidasValor += m.quantity * custoMedio;
          }
        }

        /// Atualiza saldos
        saldoQuantidade += entradasQtd - saidasQtd;
        saldoFinanceiro += entradasValor - saidasValor;

        /// Recalcula custo médio (apenas se houver saldo)
        if (saldoQuantidade > 0) {
          custoMedio = saldoFinanceiro / saldoQuantidade;
        } else {
          custoMedio = 0.0;
        }

        summary.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy').format(day)),
          IntCellValue(entradasQtd),
          IntCellValue(saidasQtd),
          IntCellValue(saldoQuantidade),
          DoubleCellValue(double.parse(custoMedio.toStringAsFixed(2))),
          DoubleCellValue(double.parse(saldoFinanceiro.toStringAsFixed(2))),
        ]);

        for (var col = 1; col < 6; col++) {
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

        final Map<String, int> qtyEntrada = {};
        final Map<String, double> totalCusto = {};

        int addDay = 0;
        int removeDay = 0;
        double totalCostDay = 0;

        for (final m in dayMovements) {
          final product = productMap[m.productId];

          if (m.type == 'add') {
            addDay += m.quantity;

            qtyEntrada[m.productId] =
                (qtyEntrada[m.productId] ?? 0) + m.quantity;

            totalCusto[m.productId] =
                (totalCusto[m.productId] ?? 0) + (m.unitPrice * m.quantity);

            totalCostDay += m.unitPrice * m.quantity;
          }

          if (m.type == 'remove') {
            removeDay += m.quantity;
          }

          final qty = qtyEntrada[m.productId] ?? 0;
          final total = totalCusto[m.productId] ?? 0;
          final custoMedio = qty == 0 ? 0 : total / qty;

          sheet.appendRow([
            TextCellValue(DateFormat('HH:mm').format(m.timestamp)),
            TextCellValue(m.productName),
            TextCellValue(m.type == 'add' ? 'Entrada' : 'Saída'),
            IntCellValue(m.quantity),
            TextCellValue(product?.barcode ?? ''),
            TextCellValue(product?.category ?? ''),
            TextCellValue(
              'R\$ ${custoMedio.toStringAsFixed(2).replaceAll('.', ',')}',
            ),
            TextCellValue(
              'R\$ ${m.unitPrice.toStringAsFixed(2).replaceAll('.', ',')}',
            ),
            IntCellValue(product?.quantity ?? 0),
            IntCellValue(product?.minStock ?? 0),
          ]);

          final row = sheet.maxRows - 1;
          final style = m.type == 'add'
              ? ExcelStyles.colorEntrada
              : ExcelStyles.colorSaida;

          for (var col = 0; col < 10; col++) {
            sheet
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: col,
                        rowIndex: row,
                      ),
                    )
                    .cellStyle =
                style;
          }
        }

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
