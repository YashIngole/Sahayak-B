import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahayak/Themeconst.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return Scaffold(
      backgroundColor: kbackgroundcolor,
      appBar: AppBar(
        backgroundColor: kbackgroundcolor,
        title: Text("Sent Requests", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Replace "your_custom_icon" with the icon you want to use
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot>(
          future: firestore.collection('service_requests').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('No documents found');
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var document = snapshot.data!.docs[index];
                var data = document.data() as Map<String, dynamic>;
                // You can access fields of the document here
                var date = data['createdAt'];
                var Issue = data['issue'];
                var status = data['AcceptStatus'];

                return ListTile(
                  title: Text(
                    'Date: $date',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Issue: $Issue',
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                  ),
                  trailing: Text(
                    ' $status',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
