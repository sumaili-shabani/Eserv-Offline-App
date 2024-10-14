import 'dart:io';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/dgrpi_info.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/utils.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/Taxation_model.dart';

import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfGeneratorRecu {
  Future<File> generateReceiptPdfRecu({
    required String receiptNumber,
    required String date,
    required String customerName,
    required double amount,
    required Invoice invoice,
    required TaxationModel infoTaxation,
    required String connected,
    required String passager,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a6,
      build: (context) => [
        // buildHeader(invoice),
        buildHeaderTaxation(invoice, infoTaxation, connected, passager),
        SizedBox(height: 0.2 * PdfPageFormat.cm),
        buildTitleTaxation(infoTaxation, passager),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(),
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/recutaxation.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /*
  *
  *=======================
  * mes script entete
  *=======================
  *
  */

  //header
  static Widget buildHeaderTaxation(
      Invoice invoice, TaxationModel note, String agent, String passager) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 0.1 * PdfPageFormat.cm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 90,
              width: 140,
              child: infoEntreprise(),
            ),
            Container(
              height: 90,
              width: 90,
              child: BarcodeWidget(
                barcode: Barcode.qrCode(),
                data:
                    'Réf de la note : ${note.codeNote.toString()} - ${note.nomCompletCb.toString()} ${invoice.items[0].description.toString()} : $netTotal  Usd',
                height: 110,
                width: 110,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.2 * PdfPageFormat.cm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildCustomerAddressTaxation(note, passager),
            buildInvoiceInfoTaxation(note, agent),
          ],
        ),
      ],
    );
  }

  static Widget infoEntreprise() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(DGRPIInfo.entete,
                maxLines: 8,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                )),
          ),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // Text('Banque: ${DGRPIInfo.banque}',
          //     maxLines: 4,
          //     style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // Text('Compte USD : ${DGRPIInfo.compteBancaireUsd}',
          //     maxLines: 4,
          //     style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // Text('Compte CDF : ${DGRPIInfo.compteBancaireCdf}',
          //     maxLines: 4,
          //     style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
        ],
      );

  static Widget buildTitleTaxation(TaxationModel note, String passager) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'QUITTANCE-${DateTime.now().year}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 0.05 * PdfPageFormat.cm),
        ],
      );

  static Widget buildCustomerAddressTaxation(
          TaxationModel note, String passager) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contribuable:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(
              note.nomCompletCb.toString() != ''
                  ? note.nomCompletCb.toString()
                  : note.nomEts.toString(),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 0.1 * PdfPageFormat.cm),
          Text('Passager: $passager',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
        ],
      );

  static Widget buildInvoiceInfoTaxation(TaxationModel note, String agent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 150,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 1, 1, 1),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('N° Réf: ${note.codeNote}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(height: 1 * PdfPageFormat.mm),
                      Text(
                          'Date: ${DateFormat("d/M/y").format(DateTime.parse(note.dateTaxation.toString()))}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(height: 1 * PdfPageFormat.mm),
                      Text('Agent: $agent',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ])))
      ],
    );
  }
  /*
  *
  *=======================
  * mes script entete
  *=======================
  *
  */

  //header
  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
              Container(
                height: 150,
                width: 150,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: invoice.info.number,
                  height: 150,
                  width: 150,
                ),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  /*
  *
  *=======================
  * En tete
  *=======================
  */
  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(customer.address),
        ],
      );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fist PDF',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = ['Désignation', 'Quantité', 'Prix Usd', 'Total Usd'];
    final data = invoice.items.map((item) {
      final total = item.quantity * item.unitPrice;

      return [
        item.description,
        item.quantity,
        item.unitPrice,
        total.toStringAsFixed(1),
      ];
    }).toList();

    // ignore: deprecated_member_use
    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // buildText(
                //   title: 'Montant:',
                //   titleStyle: TextStyle(
                //     fontSize: 9,
                //     fontWeight: FontWeight.bold,
                //   ),
                //   value: Utils.formatPrice(netTotal),
                //   unite: true,
                // ),
                // Divider(),
                buildText(
                  title: 'Total Payé:',
                  titleStyle: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //footer
  static Widget buildFooter() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 0.5 * PdfPageFormat.mm),
          buildSimpleText(title: 'Addresse:', value: DGRPIInfo.adresse),
          SizedBox(height: 0.5 * PdfPageFormat.mm),
          buildSimpleText(title: 'site web:', value: DGRPIInfo.siteweb),
        ],
      );
  // style de text
  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontSize: 8, fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, maxLines: 4, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value, maxLines: 4, style: style),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style =
        titleStyle ?? TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
