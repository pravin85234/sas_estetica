import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sas_estetica/cartscreen.dart';
import 'package:sas_estetica/spaprovider.dart';
import 'spa.dart';

class SpaDetailScreen extends StatelessWidget {
  final String shopName;

  SpaDetailScreen({required this.shopName});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpaProvider>(context);
    final spa = provider.selectedSpa!;

    final services = [
      {"name": "Swedish Massage", "price": 4000, "type": "Walkin"},
      {"name": "Deep Tissue Massage", "price": 6200, "type": "Walkin"},
      {"name": "Hot Stone Massage", "price": 8500, "type": "Homevisit"},
    ];

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(spa.imagePath, height: 280, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: BackButton(color: Colors.black),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.store, color: Colors.white)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spa.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Row(children: [
                              Text(spa.address),
                              SizedBox(width: 10),
                              Text('${spa.distance} km'),
                              SizedBox(width: 10),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Text('${spa.rating}'),
                            ]),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(child: Text("Use code DSaloon - Get ₹500 off on orders above 100/-")),
                        ],
                      ),
                    ),
                    // SizedBox(height: 20),
                    // Wrap(
                    //   spacing: 8,
                    //   children: ["All", "Home-visit", "Walk-in", "Male", "Female"]
                    //       .map((filter) => Chip(label: Text(filter)))
                    //       .toList(),
                    // ),
                    SizedBox(height: 20),
                    Text("Massage Therapy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...services.map((Map<String, dynamic> service) {
                      final isSelected = provider.selectedServices.contains(service['name']);
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(service['name'] ?? ''),
                          subtitle: Text("₹${service['price']} • 60 Mins • ${service['type']}"),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.grey[300] : Colors.white,
                            ),
                            onPressed: () => provider.toggleService(service['name']),
                            child: Text(isSelected ? "Remove" : "Add"),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
          if (provider.selectedCount > 0)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Provider.of<SpaProvider>(context, listen: false).setAllServices(services);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartScreen( allServices: services,  shopName: shopName,)),
                  );
                },

                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${provider.selectedCount} Services added", style: TextStyle(color: Colors.white)),
                      Text("Check out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            )

        ],
      ),
    );
  }
}
