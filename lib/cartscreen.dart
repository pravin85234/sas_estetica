import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sas_estetica/showShopsData.dart';

import 'spaprovider.dart';

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allServices;
  final String shopName;

  CartScreen({required this.allServices, required this.shopName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpaProvider>(context);
    final selectedServices = provider.getSelectedServiceDetails();
    final totalPrice = provider.getTotalPrice();
    final convenienceFee = 100;
    final additionalFee = 50;
    final payable = totalPrice + convenienceFee + additionalFee;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: BackButton(color: Colors.black),
        title: Text("Cart", style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Services Order",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  // onTap: () {
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (context) => Showshopsdata(categoryFilter: 'Massage Therapist'),
                  //     ),
                  //   );
                  // },
                  child: Text(
                    "+ Add more",
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...selectedServices.map(
              (service) => ListTile(
                title: Text(service['name']),
                subtitle: Text("For Male\n₹${service['price']} • 60 Mins"),
                isThreeLine: true,
                trailing: OutlinedButton(
                  onPressed: () => provider.toggleService(service['name']),
                  child: Text("Remove"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown,
                    side: BorderSide(color: Colors.brown),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Offers & Discounts",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.local_offer_outlined, color: Colors.brown),
                title: Text("Apply Coupon"),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Payment Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    summaryRow("Selected Services", "₹$totalPrice"),
                    summaryRow("Additional Fee", "₹$additionalFee"),
                    summaryRow("Convenience Fee", "₹$convenienceFee"),
                    Divider(),
                    summaryRow("Payable Amount", "₹$payable", isBold: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total ₹$payable",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedServices.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please add services to cart before proceeding.",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) => BookingConfirmationDialog(
                    services: selectedServices
                        .map((s) => s['name'].toString())
                        .toList(),
                    appointmentDateTime: DateTime(2024, 3, 7, 8, 0),
                    shopName: shopName,
                    paidAmount: payable.toDouble(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Color(0xFFB7935F),
              ),
              child: Text("Pay", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}

class BookingConfirmationDialog extends StatefulWidget {
  final List<String> services;
  final DateTime appointmentDateTime;
  final String shopName;
  final double paidAmount;

  BookingConfirmationDialog({
    required this.services,
    required this.appointmentDateTime,
    required this.shopName,
    required this.paidAmount,
  });

  @override
  _BookingConfirmationDialogState createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  late String paymentId;

  @override
  void initState() {
    super.initState();
    // Generate default payment ID, for example:
    paymentId = "PAY" + DateTime.now().millisecondsSinceEpoch.toString();

    _saveBookingData();
  }

  Future<void> _saveBookingData() async {
    final prefs = await SharedPreferences.getInstance();

    // Construct a booking info map
    final bookingInfo = {
      "paymentId": paymentId,
      "shopName": widget.shopName,
      "services": widget.services.join(", "),
      "paidAmount": widget.paidAmount.toString(),
      "appointmentDate": widget.appointmentDateTime.toIso8601String(),
    };

    await prefs.setString(paymentId, bookingInfo.toString());

    List<String> allPaymentIds = prefs.getStringList("allPaymentIds") ?? [];
    if (!allPaymentIds.contains(paymentId)) {
      allPaymentIds.add(paymentId);
      await prefs.setStringList("allPaymentIds", allPaymentIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE, d MMM y',
    ).format(widget.appointmentDateTime);
    final formattedTime = DateFormat(
      'h:mm a',
    ).format(widget.appointmentDateTime);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.brown.shade100,
              child: Icon(Icons.check, size: 40, color: Colors.white),
              foregroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            Text(
              "Your Service Booking is\nConfirmed!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Payment ID: $paymentId",
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Thank you for choosing ${widget.shopName}.\nYour appointment for ",
              textAlign: TextAlign.center,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.services.join(" and "),
                    style: TextStyle(color: Colors.brown),
                  ),
                  TextSpan(text: " has been successfully booked."),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Your appointment on $formattedDate\nat $formattedTime",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Showshopsdata()),
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Color(0xFFB7935F),
              ),
              child: Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
