import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/payment/stone_payment_widget.dart';
import '../../services/stone_payment_service.dart';

class ProcessSaleScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final String? customerName;
  final String? customerDocument;

  const ProcessSaleScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    this.customerName,
    this.customerDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processar Pagamento'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pedido #$orderId',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (customerName != null) ...[
                  Text(
                    'Cliente: $customerName',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                if (customerDocument != null) ...[
                  Text(
                    'Documento: $customerDocument',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                StonePaymentWidget(
                  amount: amount,
                  orderId: orderId,
                  customerName: customerName,
                  customerDocument: customerDocument,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
