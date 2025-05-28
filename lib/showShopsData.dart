import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sas_estetica/loginscreen.dart';
import 'package:sas_estetica/spa.dart';
import 'package:sas_estetica/spadetailsscreen.dart';
import 'package:sas_estetica/spaprovider.dart';

class Showshopsdata extends StatefulWidget {
  @override
  _SpaListScreenState createState() => _SpaListScreenState();
}

class _SpaListScreenState extends State<Showshopsdata> {
  List<Spa> _allSpas = [];
  List<Spa> _filteredSpas = [];
  String searchText = '';
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    fetchSpaListRequest();
  }

  Future<void> fetchSpaListRequest() async {
    try {
      setState(() {
        isloading = true;
      });

      bool internet = await check();
      if (internet) {
        await Future.delayed(Duration(seconds: 1));

        List<Spa> spaList = [
          Spa(name: 'Renew Day Spa', address: 'Madhapur', gender: 'Unisex', rating: 4.5, distance: 3.5, hasOffer: true, imagePath: 'assets/spa1.jpg'),
          Spa(name: 'Mystical Mantra Spa', address: 'Kukatpally', gender: 'Male', rating: 4.2, distance: 7.0, hasOffer: false, imagePath: 'assets/spa2.jpg'),
          Spa(name: 'Bodhi Retreat Spa', address: 'Kukatpally', gender: 'Female', rating: 3.9, distance: 11.0, hasOffer: true, imagePath: 'assets/spa3.jpg'),
          Spa(name: 'Eternal Bliss', address: 'Madhapur', gender: 'Unisex', rating: 3.0, distance: 5.5, hasOffer: true, imagePath: 'assets/spa4.jpg'),
          Spa(name: 'Crystal Spa', address: 'Ameerpet', gender: 'Male', rating: 4.3, distance:8.0, hasOffer: false, imagePath: 'assets/spa6.jpg'),
          Spa(name: 'Dreams Spa', address: 'Ameerpet', gender: 'Female', rating: 4.2, distance: 3.0, hasOffer: true, imagePath: 'assets/spa7.jpg'),
          Spa(name: 'Epic Spa', address: 'HitechCity', gender: 'Unisex', rating: 4.1, distance: 2.2, hasOffer: true, imagePath: 'assets/spa3.jpg'),
          Spa(name: 'Flora Spa', address: 'HitechCity', gender: 'Male', rating: 4.5, distance: 1.0, hasOffer: false, imagePath: 'assets/spa2.jpg'),
          Spa(name: 'Zen Spa', address: 'Madhapur', gender: 'Female', rating: 4.5, distance: 2.5, hasOffer: true, imagePath: 'assets/spa4.jpg'),
        ];

        setState(() {
          _allSpas = spaList;
          _filteredSpas = spaList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection")),
        );
      }
    } catch (e) {
      print("Spa list fetch failed: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<bool> check() async {
    try {
      var connect = await Connectivity().checkConnectivity();
      if (connect == ConnectivityResult.mobile) {
        return true;
      } else if (connect == ConnectivityResult.wifi) {
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  void _filterSpas(String query) {
    setState(() {
      _filteredSpas = _allSpas.where((spa) =>
      spa.name.toLowerCase().contains(query.toLowerCase()) ||
          spa.address.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Loginscreen()),
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text("Spas"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.location_on, color: Colors.orange),
        actions: [Icon(Icons.notifications_none_outlined, color: Colors.orange)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterSpas,
              decoration: InputDecoration(
                hintText: 'Search Spa, Services.',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSpas.length,
              itemBuilder: (context, index) {
                final spa = _filteredSpas[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      final selectedSpa = _filteredSpas[index];

                      Provider.of<SpaProvider>(context, listen: false).setSelectedSpa(selectedSpa);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpaDetailScreen(shopName: selectedSpa.name),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(spa.imagePath, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(spa.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spa.address, style: TextStyle(fontSize: 12)),
                        Text(spa.gender, style: TextStyle(fontSize: 12)),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            Text('${spa.rating}'),
                            SizedBox(width: 8),
                            Icon(Icons.location_on, size: 16),
                            Text('${spa.distance} km'),
                          ],
                        ),
                        if (spa.hasOffer)
                          Row(
                            children: [
                              Icon(Icons.local_offer, color: Colors.green, size: 16),
                              Text(" Flat 10% Off above value of 200", style: TextStyle(color: Colors.green)),
                            ],
                          ),
                      ],
                    ),
                    trailing: Icon(Icons.favorite_border, color: Colors.brown),
                  ),
                );

              },
            ),
          ),
        ],
      ),),
    );
  }

}
