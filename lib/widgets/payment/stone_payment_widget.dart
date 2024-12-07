import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/stone_payment_service.dart';

class StonePaymentWidget extends StatelessWidget {
  final double amount;
  final String orderId;
  final String? customerName;
  final String? customerDocument;

  const StonePaymentWidget({
    Key? key,
    required this.amount,
    required this.orderId,
    this.customerName,
    this.customerDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stoneService = StonePaymentService.to;

    return Obx(() {
      if (stoneService.isProcessing) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PaymentButton(
                icon: Icons.credit_card,
                label: 'Crédito',
                onPressed: () => _processPayment(PaymentType.credit),
              ),
              _PaymentButton(
                icon: Icons.credit_card,
                label: 'Débito',
                onPressed: () => _processPayment(PaymentType.debit),
              ),
              _PaymentButton(
                icon: Icons.qr_code,
                label: 'PIX',
                onPressed: () => _processPayment(PaymentType.pix),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total: R\$ ${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      );
    });
  }

  Future<void> _processPayment(PaymentType type) async {
    final stoneService = StonePaymentService.to;

    try {
      if (!await stoneService.checkPinpadConnection()) {
        Get.snackbar(
          'Erro',
          'Pinpad não conectada',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final installments = type == PaymentType.credit ? 1 : 0;
      final result = await stoneService.makePayment(
        amount: amount,
        orderId: orderId,
        installments: installments,
        paymentType: type,
        customerName: customerName,
        customerDocument: customerDocument,
      );

      if (result['status'] == 'approved') {
        // Imprimir via do estabelecimento
        await stoneService.printReceipt(
          transactionId: result['transactionId'],
          isCustomerCopy: false,
        );

        // Imprimir via do cliente
        await stoneService.printReceipt(
          transactionId: result['transactionId'],
          isCustomerCopy: true,
        );

        Get.back(result: result);
      } else {
        Get.snackbar(
          'Erro',
          'Pagamento não aprovado',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _PaymentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PaymentButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }
}
