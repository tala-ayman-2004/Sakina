import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Singup extends StatefulWidget {
  const Singup({super.key});

  @override
  State<Singup> createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> k = GlobalKey<FormState>();

  Future<void> signupm(BuildContext context) async {
    if (!k.currentState!.validate()) return;

    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      User? user = cred.user;

      if (user != null) {
        // Store user in Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "username": username.text.trim(),
          "email": email.text.trim(),
          "createdAt": FieldValue.serverTimestamp(),
          "emailVerified": false,
        });

        // Send verification email
        if (!user.emailVerified) {
          await user.sendEmailVerification();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Verification email sent. Please verify your email.",
              ),
            ),
          );

          checkEmailVerified();
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    }
  }

  // ================= CHECK VERIFICATION =================
  void checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user!.emailVerified) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({"emailVerified": true});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verified successfully")),
        );

        Navigator.pop(context); 
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2B2D30),
      ),
      backgroundColor: const Color(0xFF2B2D30),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100),
        
        child: Center(
          child: Form(
            key: k,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo1.png",
                  width: 300,
                  height: 300,
                ),
        
                // USERNAME
                field(
                  controller: username,
                  icon: Icons.person,
                  hint: "Username",
                  validator: vUsername,
                ),
        
                const SizedBox(height: 16),
        
                // EMAIL
                field(
                  controller: email,
                  icon: Icons.email,
                  hint: "Email",
                  validator: vEmail,
                ),
        
                const SizedBox(height: 16),
        
                // PASSWORD
                field(
                  controller: password,
                  icon: Icons.lock,
                  hint: "Password",
                  obscure: true,
                  validator: vPassword,
                ),
        
                const SizedBox(height: 16),
        
                // CONFIRM PASSWORD
                field(
                  controller: confirmPassword,
                  icon: Icons.lock_outline,
                  hint: "Confirm Password",
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Confirm your password";
                    }
                    if (v != password.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
        
                const SizedBox(height: 20),
        
                TextButton(
                  onPressed: () => signupm(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF229B91),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= FIELD BUILDER =================
  Widget field({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    bool obscure = false,
  }) {
    return SizedBox(
      height: 50,
      width: 300,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ================= VALIDATORS =================
String? vUsername(String? v) {
  if (v == null || v.trim().length < 3) {
    return "Username must be at least 3 characters";
  }
  return null;
}

String? vEmail(String? v) {
  if (v == null || v.isEmpty) return "Email is required";
  if (!v.contains("@") || !v.contains(".")) {
    return "Enter a valid email";
  }
  return null;
}

String? vPassword(String? v) {
  if (v == null || v.isEmpty) return "Password is required";
  if (v.length < 8) {
    return "Password must be at least 8 characters";
  }
  return null;
}
