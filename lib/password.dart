import 'package:flutter/material.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2B2D30),
      ),
      backgroundColor: const Color(0xFF2B2D30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/logo1.png"),
              width: 300,
              height: 300,
            ),
            SizedBox(
              height: 50,
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                  hintText: 'Enter your Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Handle Reset action
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF229B91),
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'send a reset link',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
