import 'package:flutter/material.dart';

class PaymentMethodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
      ),
      body: ListView(
        children: [
          _buildPaymentMethodOption(
            image: Image.asset("assets/images/visa1.png"),
            label: 'Visa',
            onPressed: () {
              // Handle Visa payment method selection
            },
          ),
          _buildPaymentMethodOption(
            image: Image.asset("assets/images/master.png"),
            label: 'MasterCard',
            onPressed: () {
              // Handle MasterCard payment method selection
            },
          ),
          _buildPaymentMethodOption(
            image: Image.asset("assets/images/paypal.png"),
            label: 'PayPal',
            onPressed: () {
              // Handle PayPal payment method selection
            },
          ),
          _buildPaymentMethodOption(
            image: Image.asset("assets/images/amex.png"),
            label: 'American Express',
            onPressed: () {
              // Handle American Express payment method selection
            },
          ),
          _buildPaymentMethodOption(
            image: Image.asset("assets/images/gpay.png"),
            label: 'Google Pay',
            onPressed: () {
              // Handle Google Pay payment method selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required Image image,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: EdgeInsets.all(4.0),
      child: PaymentMethodOption(
        image: image,
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}

class PaymentMethodOption extends StatelessWidget {
  final Image image;
  final String label;
  final VoidCallback onPressed;

  const PaymentMethodOption({
    Key? key,
    required this.image,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: image,
      title: Text(label),
      onTap: onPressed,
    );
  }
}

