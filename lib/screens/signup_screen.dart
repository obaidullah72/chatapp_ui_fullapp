// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:fluter_chat_app_provider/screens/home_screen.dart';
// import 'package:fluter_chat_app_provider/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//
//   File? _image;
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   final _storage = FirebaseStorage.instance;
//
//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       }
//     });
//   }
//
//   Future<String> _uploadImage(File image) async {
//     final ref = _storage
//         .ref()
//         .child('user_images')
//         .child('${_auth.currentUser!.uid}.jpg');
//
//     await ref.putFile(image);
//     return await ref.getDownloadURL();
//   }
//
//   Future<void> _signUp() async {
//     try {
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passController.text,
//       );
//       final imageUrl = await _uploadImage(_image!);
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'name': _nameController.text,
//         'email': _emailController.text,
//         'imageUrl': imageUrl,
//       });
//
//       Fluttertoast.showToast(msg: "Sign Up Successfully");
//
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeScreen()));
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final authProvider = Provider.of<AuthProviders>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SignUp Screen"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               InkWell(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 200,
//                   width: 200,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(),
//                   ),
//                   child: _image == null
//                       ? Center(
//                           child: Icon(
//                             Icons.camera_alt_rounded,
//                             size: 50,
//                             color: Color(0xFF3876FD),
//                           ),
//                         )
//                       : ClipRRect(
//                           borderRadius: BorderRadius.circular(100),
//                           child: Image.file(
//                             _image!,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               TextFormField(
//                 controller: _nameController,
//                 keyboardType: TextInputType.name,
//                 decoration: InputDecoration(
//                     labelText: "Name", border: OutlineInputBorder()),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please Enter Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                     labelText: "Email", border: OutlineInputBorder()),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please Enter Email";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                 controller: _passController,
//                 keyboardType: TextInputType.visiblePassword,
//                 decoration: InputDecoration(
//                     labelText: "Password", border: OutlineInputBorder()),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please Enter Password";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 50,
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width / 1.5,
//                 height: 55,
//                 child: ElevatedButton(
//                   onPressed: _signUp,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF3876FD),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text("Create Account"),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text("OR"),
//               SizedBox(
//                 height: 10,
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()));
//                 },
//                 child: Text(
//                   "Sign In",
//                   style: TextStyle(
//                     color: Color(0xFF3876FD),
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluter_chat_app_provider/screens/home_screen.dart';
import 'package:fluter_chat_app_provider/screens/login_screen.dart';
import 'package:fluter_chat_app_provider/screens/main_screens.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );
      await userCredential.user!.updateDisplayName(_nameController.text);
      await userCredential.user!.reload();
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text,
        'email': _emailController.text,
      });

      Fluttertoast.showToast(msg: "Sign Up Successfully");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Join us and start chatting!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Password Field
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 0),
                      elevation: 5,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Already Have an Account
                Text(
                  "Already have an account?",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
