import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sakina/app_footer.dart';
import 'package:sakina/Home.dart';
import 'package:sakina/login.dart';
import 'package:sakina/prayerPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakina/login.dart';
bool notificationsEnabled = true;
bool darkModeEnabled = false;
String selectedLanguage = 'English';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  String username = '';
  String email = '';

  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ================= LOAD USER DATA =================
  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      username = doc['username'];
      email = user.email ?? '';
      usernameController.text = username;
      emailController.text = email;
    });
  }

  // ================= UPDATE USERNAME =================
  Future<void> updateUsername() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"username": usernameController.text.trim()});

    setState(() => username = usernameController.text.trim());
    _toast("Username updated");
  }
 // ================= UPDATE EMAIL ===================
 

  // ================= CHANGE PASSWORD =================
  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      _toast("Passwords do not match");
      return;
    }

    try {
      AuthCredential cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text);

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _toast("Password updated successfully");
    } catch (e) {
      _toast("Incorrect old password");
    }
  }

  Future<void> sendResetEmail() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
    _toast("Password reset email sent");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if(isGuest){
      return Scaffold(
        backgroundColor: const Color(0xFF2B2D30),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF229B91),
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You are logged in as a guest.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const login()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229B91),
                  ),
                  child: const Text('Login or Register'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF229B91),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  index == 0 ? const PrayerPage() : const Home(),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: 
        Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 20),
            _accountCard(),
            const SizedBox(height: 20),
            _passwordCard(),
            const SizedBox(height: 20),
            _settingsCard(),
          ],
        ),
      ),
    );
  }


  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFF229B91),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(username,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _accountCard() {
    return _card(
      title: 'Account',
      children: [
        _input(usernameController, 'Username', onSave: updateUsername),
      ],
    );
  }

  Widget _passwordCard() {
    return _card(
      title: 'Security',
      children: [
        _passwordField(oldPasswordController, 'Old Password'),
        const SizedBox(height: 10),
        _passwordField(newPasswordController, 'New Password'),
        const SizedBox(height: 10),
        _passwordField(confirmPasswordController, 'Confirm Password'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF229B91),
          ),
          child: const Text('Update Password'),
        ),
        TextButton(
          onPressed: sendResetEmail,
          child: const Text(
            "Send Reset Email",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _settingsCard() {
    return _card(
      title: 'Preferences',
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const login()));
          },
        ),
         ListTile(
          leading: const Icon(Icons.settings, color: Colors.white),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _input(TextEditingController c, String label,
      {required VoidCallback onSave}) {
    return TextField(
      controller: c,
      
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white10,
        suffixIcon:
            IconButton(icon: const Icon(Icons.check), onPressed: onSave),
      ),
    );
  }

  Widget _passwordField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white10,
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text(
              'Enable Notifications',
              style: TextStyle(color: Colors.white),
            ),
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: Colors.white),
            ),
            value: darkModeEnabled,
            onChanged: (v) => setState(() => darkModeEnabled = v),
          ),
          ListTile(
            title: const Text(
              'Language',
              style: TextStyle(color: Colors.white),
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1E1E1E),
              items: [
                'English',
                'Arabic',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedLanguage = v!),
            ),
          ),
        ],
      ),
    );
  }
}
