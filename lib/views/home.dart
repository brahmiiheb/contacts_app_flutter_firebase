import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_app/controllers/auth_services.dart';
import 'package:contacts_app/controllers/crud_services.dart';
import 'package:contacts_app/views/update_contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? _imageUrl; // Declare _imageUrl as a private variable
  late Stream<QuerySnapshot> _stream;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchfocusNode = FocusNode();

  @override
  void initState() {
    _stream = CRUDService().getContacts();
    super.initState();
  }

  @override
  void dispose() {
    _searchfocusNode.dispose();
    super.dispose();
  }

  // to call the contact using url launcher


  /*void callUser(String phone) async {
    if (phone == null || phone.isEmpty) {
      // Handle the case where the phone number is null or empty.
      print('Invalid phone number');
      // You might want to show an error message to the user.
      return;
    }

    String url = 'tel:$phone';

    try {
      if (Platform.isAndroid) {
        // For Android, use an explicit Intent.
        await Process.run('adb', ['shell', 'am', 'start', '-a', 'android.intent.action.CALL', Uri.encodeFull(url)]);
      } else {
        // For iOS and other platforms, use the 'url_launcher' package.
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          // Handle the case where the phone call cannot be launched.
          print('Could not launch $url');
          // You might want to show an error message to the user.
        }
      }
    } catch (e) {
      // Handle any exceptions that may occur during the launch process.
      print('Error launching $url: $e');
      // You might want to show an error message to the user.
    }
  }*/
  void callUser(String phone) async {
    if (phone.isEmpty) {
      // Handle the case where the phone number is null or empty.
      print('Invalid phone number');
      // You might want to show an error message to the user.
      return;
    }

    try {
      await FlutterPhoneDirectCaller.callNumber(phone);
    } catch (e) {
      // Handle any exceptions that may occur during the call.
      print('Error calling $phone: $e');
      // You might want to show an error message to the user.
    }
  }




  // search Function to perform search

  searchContacts(String search) {
    _stream = CRUDService().getContacts(searchQuery: search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        // search box
        bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width * 8, 80),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: TextFormField(
                    onChanged: (value) {
                      searchContacts(value);
                      setState(() {});
                    },
                    focusNode: _searchfocusNode,
                    controller: _searchController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: const Text("Search"),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _searchfocusNode.unfocus();
                                  _stream = CRUDService().getContacts();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null),
                  )),
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add");
        },
        child: const Icon(Icons.person_add),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: 32,
                child: Text(FirebaseAuth.instance.currentUser!.email
                    .toString()[0]
                    .toUpperCase()),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(FirebaseAuth.instance.currentUser!.email.toString())
            ],
          )),
          ListTile(
            onTap: () {
              AuthService().logout();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Logged Out")));
              Navigator.pushReplacementNamed(context, "/login");
            },
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Logout"),
          )
        ],
      )),
      body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something Went Wrong");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text("Loading"),
              );
            }
            return snapshot.data!.docs.isEmpty
                ? const Center(
                    child: Text("No Contacts Found ..."),
                  )
                : ListView(
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          // You can replace 'placeholder_image_url' with a default image URL
                          // or use a local image asset if you have one.
                          String imageUrl = data["imageUrl"] ?? 'placeholder_image_url';
                          return ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateContact(
                                        name: data["name"],
                                        phone: data["phone"],
                                        email: data["email"],
                                        docID: document.id,
                                      imageUrl: _imageUrl ?? '', // Use an empty string if _imageUrl is null
                                    ))),
                            //leading: CircleAvatar(child: Text(data["name"][0])),
                            leading: CircleAvatar(
                              // Use NetworkImage for loading images from the internet
                              // You can replace it with AssetImage if using local assets.
                              backgroundImage: NetworkImage(imageUrl),
                              child: Text(data["name"][0]),
                            ),
                            title: Text(data["name"]),
                            subtitle: Text(data["phone"]),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                             /* onPressed: () {
                                callUser(data["phone"]);
                              },*/
                              onPressed: () {
                               // callUser(lstContacts[index].tel);
                                callUser(data["phone"]);
                              },
                            ),
                          );
                        })
                        .toList()
                        .cast(),
                  );
          }),
    );
  }
}
