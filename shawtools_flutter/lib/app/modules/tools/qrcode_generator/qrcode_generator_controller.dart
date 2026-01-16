import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../utils/toast_utils.dart';

class QrcodeGeneratorController extends GetxController {
  final qrcodeTextController = TextEditingController();
  final barcodeTextController = TextEditingController();

  final qrcodeSize = 300.obs;
  final qrcodeErrorLevel = 'M'.obs; // L, M, Q, H
  final qrcodeColor = const Color(0xFF000000).obs;
  final qrcodeBgColor = const Color(0xFFFFFFFF).obs;
  final showQrcode = false.obs;

  final barcodeFormat = Barcode.code128().obs;
  final barcodeWidth = 2.0.obs;
  final barcodeHeight = 100.obs;
  final barcodeDisplayValue = true.obs;
  final barcodeColor = const Color(0xFF000000).obs;
  final barcodeBgColor = const Color(0xFFFFFFFF).obs;
  final showBarcode = false.obs;

  @override
  void onClose() {
    qrcodeTextController.dispose();
    barcodeTextController.dispose();
    super.onClose();
  }

  void generateQRCode() {
    final text = qrcodeTextController.text.trim();
    if (text.isEmpty) {
      ToastUtils.showError('请输入要生成二维码的内容');
      return;
    }
    showQrcode.value = true;
  }

  void clearQRCode() {
    qrcodeTextController.clear();
    showQrcode.value = false;
  }

  void generateBarcode() {
    final text = barcodeTextController.text.trim();
    if (text.isEmpty) {
      ToastUtils.showError('请输入要生成条形码的内容');
      return;
    }
    showBarcode.value = true;
  }

  void clearBarcode() {
    barcodeTextController.clear();
    showBarcode.value = false;
  }

  int get errorLevelInt {
    switch (qrcodeErrorLevel.value) {
      case 'L':
        return QrErrorCorrectLevel.L;
      case 'Q':
        return QrErrorCorrectLevel.Q;
      case 'H':
        return QrErrorCorrectLevel.H;
      case 'M':
      default:
        return QrErrorCorrectLevel.M;
    }
  }

  void setQRCodeStyle(String style) {
    switch (style) {
      case 'blue':
        qrcodeColor.value = const Color(0xFF1677FF);
        qrcodeBgColor.value = const Color(0xFFFFFFFF);
        break;
      case 'green':
        qrcodeColor.value = const Color(0xFF07C160);
        qrcodeBgColor.value = const Color(0xFFFFFFFF);
        break;
      case 'red':
        qrcodeColor.value = const Color(0xFFFF0050);
        qrcodeBgColor.value = const Color(0xFFFFFFFF);
        break;
      case 'purple':
        qrcodeColor.value = const Color(0xFF764ba2);
        qrcodeBgColor.value = const Color(0xFFFFFFFF);
        break;
      case 'gradient':
        qrcodeColor.value = const Color(0xFF667eea);
        qrcodeBgColor.value = const Color(0xFFf8f9fa);
        break;
      default:
        qrcodeColor.value = const Color(0xFF000000);
        qrcodeBgColor.value = const Color(0xFFFFFFFF);
    }
  }

  void setBarcodeFormat(String format) {
    switch (format) {
      case 'CODE128':
        barcodeFormat.value = Barcode.code128();
        break;
      case 'CODE39':
        barcodeFormat.value = Barcode.code39();
        break;
      case 'EAN13':
        barcodeFormat.value = Barcode.ean13();
        break;
      case 'EAN8':
        barcodeFormat.value = Barcode.ean8();
        break;
      case 'UPC':
        barcodeFormat.value = Barcode.upcA();
        break;
      case 'ITF14':
        barcodeFormat.value = Barcode.itf14();
        break;
      case 'MSI':
        barcodeFormat.value = Barcode.code128();
        break;
      case 'pharmacode':
        barcodeFormat.value = Barcode.code128();
        break;
      case 'codabar':
        barcodeFormat.value = Barcode.codabar();
        break;
      default:
        barcodeFormat.value = Barcode.code128();
    }
  }
}
