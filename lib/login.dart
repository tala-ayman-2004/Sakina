import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakina/singup.dart';
import 'package:sakina/password.dart';
import 'Home.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GlobalKey<FormState> k = GlobalKey<FormState>();

  Future<void> continueAsGuest(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Guest login failed")));
    }
  }

  Future<void> loginUser(BuildContext context) async {
    if (!k.currentState!.validate()) return;

    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          );

      User? user = cred.user;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
          ),
        );
        return;
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";

      if (e.code == 'user-not-found') {
        msg = "Email does not exist";
      } else if (e.code == 'wrong-password') {
        msg = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email format";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 45, 48, 1),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Form(
            key: k,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo1.png", width: 300, height: 300),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: TextFormField(
                    controller: email,
                    validator: vEmail,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
        
                const SizedBox(height: 16.0),
        
                // PASSWORD
                SizedBox(
                  height: 50,
                  width: 300,
                  child: TextFormField(
                    controller: password,
                    validator: vPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
        
                const SizedBox(height: 16.0),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Password(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    TextButton(
                      onPressed: () {
                        continueAsGuest(context);
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        
                const SizedBox(height: 16.0),
        
                TextButton(
                  onPressed: () => loginUser(context),
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
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
        
                const SizedBox(height: 16.0),
        
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Singup()),
                    );
                  },
                  child: const Text(
                    'No account? Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
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

String? vEmail(String? v) {
  if (v == null || v.isEmpty) return "Email is required";
  if (!v.contains("@") || !v.contains(".")) {
    return "Enter a valid email";
  }
  return null;
}

String? vPassword(String? v) {
  if (v == null || v.isEmpty) return "Password is required";
  if (v.length < 6) {
    return "Password must be at least 6 characters";
  }
  return null;
}
