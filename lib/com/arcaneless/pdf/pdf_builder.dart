import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';
import 'package:receiptapp/com/arcaneless/pdf/pdf_storage_handler.dart';
import 'package:receiptapp/com/arcaneless/structures/customer.dart';
import 'package:receiptapp/com/arcaneless/structures/invoice.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:html' as html;

class PdfBuilder {
  String name;
  PdfStorage storage;
  Document main;
  Document tail;

  PdfBuilder(this.name) {
    if (!kIsWeb) {
      storage = PdfStorage();
    }
  }

  // load the html template
  Future<PdfBuilder> _loadHTMLs() async {
    String htmlMain = await rootBundle.loadString('templates/invoice.html');
    String htmlTail = await rootBundle.loadString('templates/tail.html');
    main = parse(htmlMain);
    tail = parse(htmlTail);
    return this;
  }

  // Calculate job table length in pdf
  // Parameters
  final double tableInitialLength = 54.0; // 44 + 10 margin (pre ratio height)
  final double tablePerRowLength = 20.0;// add also if multiline  (pre ratio height)
  double calculateTableLength(List<Job> jobs) {
    double length = tableInitialLength;
    jobs.forEach((job) {
      length += tablePerRowLength * (job.objectName.length / 22 + 1);
    });
    return length;
  }

  Future<PdfBuilder> addInvoice(Invoice invoice) async {
    await _loadHTMLs();


    // Customer Information
    main.getElementById('customer_name').text = invoice.customer.name;
    main.getElementById('customer_tel').text = invoice.customer.telno;
    main.getElementById('customer_address').text = invoice.customer.address;



    // page break clone then dump
    Element pageBreakOrg = main.getElementsByClassName("page-break")[0].clone(true);
    main.getElementsByClassName("page-break")[0].remove(); // remove

    // second page clone then dump
    Element pageOrg = main.getElementsByClassName("page")[1].clone(true);
    main.getElementsByClassName("page")[1].remove(); // remove

    // total total clone then dump
    Element totalOrg = main.getElementsByClassName("total")[0].clone(true);
    main.getElementsByClassName("total")[0].remove(); // remove

    // Table clone then dump
    Element tableEleOrg = main.getElementsByClassName("jobdetails")[0].clone(true); // inital 1
    main.getElementsByClassName("jobdetails")[0].remove(); // remove



    // Tables input
    int i=1; // list index
    final double firstPageInitalLength = (130.0 + 85.0 + 26.0);
    final double secondPageInitalLength = (130.0 + 20.0);
    final double maxLength = 1080;
    int pageIndex=0;
    double pageLength = firstPageInitalLength;
    invoice.jobsNameChinese.forEach((key, value) {
      // Page checking
      List<Job> targetList = invoice.jobs.where((element) => element.typeId == key).toList();
      // If no item, skip it
      if (targetList.isEmpty) {
        return;
      }

      double thisListLength = calculateTableLength(targetList);
      pageLength += thisListLength;
      Logger().i("$value, current page length: $pageLength");
      if (pageLength > maxLength) {
        pageLength = secondPageInitalLength + thisListLength;
        pageIndex++;
        // Log checking
        Logger().i("Page Index: $pageIndex");

        // next page dom action, aka. add page
        main.body.append(pageBreakOrg.clone(true));
        main.body.append(pageOrg.clone(true));
      }



      Element table = tableEleOrg.clone(true);
      table.getElementsByClassName('list_index')[0].text = '$i.';
      table.getElementsByClassName('list_name')[0].text = value;
      table.getElementsByClassName('list_total_name')[0].text = '$value小計';
      table.getElementsByClassName('list_total')[0].text = invoice.getCategoryTotalPrice(key).toStringAsFixed(1);


      // job row template
      Element rowEleOrg = table.getElementsByClassName('job_row')[0].clone(true);
      table.getElementsByClassName('job_row')[0].remove();
      // Elements details iteration
      int j = 1; // iteration
      invoice.jobs.where((element) => element.typeId == key).forEach((element) {
        Element row = rowEleOrg.clone(true);

        row.children[0].text = '$i.$j'; // index
        row.children[1].text = element.objectName; // name

        if (element.jobState == JobState.Single) {

          row.children[2].text = element.pricePerUnit.toStringAsFixed(1); // per_unit_price
          row.children[3].text = element.amount.toStringAsFixed(1); // amount
          row.children[4].text = element.unit; // unit
          row.children[5].text = element.totalPrice.toStringAsFixed(1); // total_price

        } else if (element.jobState == JobState.Multiple) {

          row.children[4].text = '第${element.range[0]}-${element.range[1]}項'; // range
          row.children[5].text = element.pricePerUnit.toStringAsFixed(1); // total_price

        } else {

          row.children[5].text = element.jobState.to_string(); // total_price

        }


        j++;
        table.children[2].append(row);

      });



      main.getElementsByClassName("page")[pageIndex].append(table);
      i++;
    });

    // add total total price
    if (pageLength + 20 > maxLength) {
      pageLength = secondPageInitalLength + 20;
      pageIndex++;
      // Log checking
      Logger().i("Page Index: $pageIndex");

      // next page dom action, aka. add page
      main.body.append(pageBreakOrg.clone(true));
      main.body.append(pageOrg.clone(true));
    }
    // add total price
    main.getElementsByClassName("page")[pageIndex].append(totalOrg);
    double totalTotalPrice = invoice.totalTotalPrice;
    main.getElementById('total_total_price').text = totalTotalPrice.toStringAsFixed(1);


    // add job done date, etc
    if (pageLength + 720 > maxLength) {
      pageLength = secondPageInitalLength + 350;
      pageIndex++;
      // Log checking
      Logger().i("Page Index: $pageIndex");

      // next page dom action, aka. add page
      main.body.append(pageBreakOrg.clone(true));
      main.body.append(pageOrg.clone(true));
    }
    // add job done date
    main.getElementsByClassName("page")[pageIndex].append(tail.body.children[0]);
    // element control of tail
    main.getElementsByClassName('total-price')[0].text = totalTotalPrice.toStringAsFixed(1);

    // modifying the content of payment arrangements
    invoice.paymentArrangements.asMap().forEach((key, value) {
      main.getElementsByClassName('money-split-percentage${key+1}')[0].text = '${value.percentageSplit}%';
      main.getElementsByClassName('money-split-when-to-pay${key+1}')[0].text = value.whenToPay;
      main.getElementsByClassName('money-split${key+1}')[0].text = (totalTotalPrice * value.percentageSplit / 100).toStringAsFixed(1);
    });


    // Adding date
    // Invoice date
    DateFormat formatter1 = DateFormat('yyyy-MM-dd');
    main.getElementsByClassName('invoice-date').forEach((e) {
      e.text = formatter1.format(invoice.invoiceDate);
    });
    DateFormat formatter2 = DateFormat('yyyy 年 MM 月 dd 日');
    main.getElementsByClassName('start-date')[0].text = formatter2.format(invoice.startDate);
    main.getElementsByClassName('end-date')[0].text = formatter2.format(invoice.endDate);


    //Logger().i(main.outerHtml); // LOG
    return this;
  }

  // check if directory exists
  Future<void> checkDirectory() async {
    await storage.checkRawDirectory();
  }

  // write to temp directory
  Future<String> save() async {
    if (kIsWeb) {
      main.head.append(Element.html('<meta charset="utf-8">'));
      Logger().i(main.outerHtml);
      final bytes = utf8.encode(main.outerHtml);
      // final blob = html.Blob([bytes], 'text/html');
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // html.window.open(url, name);

      // html.Url.revokeObjectUrl(url);
      return '';
    } else {
      await checkDirectory();

      final path = await storage.localPath;
      File file = await FlutterHtmlToPdf.convertFromHtmlContent(main.outerHtml, '$path/pdf/', name);
      return '$path/pdf/$name.pdf';
    }
  }
}
