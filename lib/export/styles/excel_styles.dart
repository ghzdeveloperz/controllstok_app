// lib/export/styles/excel_styles.dart
import 'package:excel/excel.dart';

class ExcelStyles {
  ExcelStyles._();

  static final CellStyle coverTitle = CellStyle(
    bold: true,
    fontSize: 22,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
  );

  static final CellStyle sheetTitle = CellStyle(
    bold: true,
    fontSize: 18,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
  );

  static final CellStyle resumoGeralTitle = CellStyle(
    bold: true,
    fontSize: 20,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
  );

  static final CellStyle centerNoBorder = CellStyle(
    fontSize: 12,
    horizontalAlign: HorizontalAlign.Center,
  );

  static final CellStyle header = CellStyle(
    bold: true,
    fontSize: 13,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );

  static final CellStyle left = CellStyle(
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );

  static final CellStyle dataCenterSmall = CellStyle(
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );

  static final CellStyle summaryTitle = CellStyle(
    bold: true,
    fontSize: 15,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
    topBorder: Border(borderStyle: BorderStyle.Medium),
    bottomBorder: Border(borderStyle: BorderStyle.Medium),
    leftBorder: Border(borderStyle: BorderStyle.Medium),
    rightBorder: Border(borderStyle: BorderStyle.Medium),
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
  );

  static final CellStyle total = CellStyle(
    bold: true,
    fontSize: 12,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    topBorder: Border(borderStyle: BorderStyle.Medium),
    bottomBorder: Border(borderStyle: BorderStyle.Medium),
    leftBorder: Border(borderStyle: BorderStyle.Medium),
    rightBorder: Border(borderStyle: BorderStyle.Medium),
    backgroundColorHex: ExcelColor.black,
    fontColorHex: ExcelColor.white,
  );

  /* ===== NOVOS ESTILOS ===== */

  /// 🟢 Entradas — verde claro, elegante e não agressivo
  static final CellStyle colorEntrada = CellStyle(
    fontSize: 10,
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.green200,
    fontColorHex: ExcelColor.white30,
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );

  /// 🔴 Saídas — vermelho claro, discreto e profissional
  static final CellStyle colorSaida = CellStyle(
    fontSize: 10,
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.red200,
    fontColorHex: ExcelColor.white30,
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );


  // percentual

  static final CellStyle percent = CellStyle(
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    numberFormat: NumFormat.custom(formatCode: '0.00%'),
    topBorder: Border(borderStyle: BorderStyle.Thin),
    bottomBorder: Border(borderStyle: BorderStyle.Thin),
    leftBorder: Border(borderStyle: BorderStyle.Thin),
    rightBorder: Border(borderStyle: BorderStyle.Thin),
  );
}
