import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/locale_provider.dart';
import 'package:lookup/providers/theme_provider.dart';
import 'package:lookup/screens/login_screen.dart';
import 'package:lookup/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  String? avatarPath;
  bool isEditing = false;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      usernameController.text = authProvider.currentUser!.username;
      emailController.text = authProvider.currentUser!.email;
      avatarPath = authProvider.currentUser!.avatar;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        avatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.updateProfile(
        usernameController.text.trim(),
        emailController.text.trim(),
        avatarPath,
      );

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.profileUpdateSuccess,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14,
        );
        setState(() {
          isEditing = false;
        });
      } else if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.profileUpdateFailed,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmimationText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUserAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTitle),
        content: Text(AppLocalizations.of(context)!.deleteWarningText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.currentUser != null) {
                bool success = await authProvider.deleteUserAccount(
                  authProvider.currentUser!.id!,
                );
                if (success && mounted) {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.successAccountDelete,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                } else if (mounted) {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.failedAccountDelete,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.deleteButtonText,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              icon: Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: avatarPath != null
                          ? DecorationImage(
                              image: FileImage(File(avatarPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarPath == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                  if (isEditing)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 24),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (isEditing)
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.username,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emptyUsername;
                        }
                        if (value.length < 3) {
                          return AppLocalizations.of(
                            context,
                          )!.usernameNotComplete;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emptyEmail;
                        }
                        if (!RegExp(
                          r'[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value.trim())) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: AppLocalizations.of(context)!.save,
                            onPressed: _saveProfile,
                          ),
                        ),

                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                usernameController.text =
                                    authProvider.currentUser!.username;
                                emailController.text =
                                    authProvider.currentUser!.email;
                                avatarPath = authProvider.currentUser!.avatar;
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(AppLocalizations.of(context)!.username),
                        subtitle: Text(
                          authProvider.currentUser?.username ?? '',
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.email_rounded),
                        title: Text('Email'),
                        subtitle: Text(authProvider.currentUser?.email ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.calendar_today_rounded),
                        title: Text(AppLocalizations.of(context)!.memberSince),
                        subtitle: Text(
                          authProvider.currentUser?.createdAt.year.toString() ??
                              '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 20),

            //Theme mode
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appearance,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(
                            AppLocalizations.of(context)!.light,
                            style: TextStyle(fontSize: 10),
                          ),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(
                            AppLocalizations.of(context)!.dark,
                            style: TextStyle(fontSize: 10),
                          ),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text(
                            AppLocalizations.of(context)!.system,
                            style: TextStyle(fontSize: 10),
                          ),
                          icon: Icon(Icons.settings_rounded),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        themeProvider.setThemeMode(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.language,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: Icon(Icons.language_rounded),
                                title: Text(
                                  AppLocalizations.of(context)!.english,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing:
                                    localeProvider.locale.languageCode == 'en'
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                      )
                                    : null,
                                onTap: () {
                                  localeProvider.setLocale(Locale('en'));
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                leading: Icon(Icons.language_rounded),
                                title: Text(
                                  AppLocalizations.of(context)!.french,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing:
                                    localeProvider.locale.languageCode == 'fr'
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                      )
                                    : null,
                                onTap: () {
                                  localeProvider.setLocale(Locale('fr'));
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    // Logout section
                    Text(
                      AppLocalizations.of(context)!.logout,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    OutlinedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.login_rounded, color: Colors.red),
                      label: Text(
                        AppLocalizations.of(context)!.logout,
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                Column(
                  // Delete Account Section
                  children: [
                    Text(
                      AppLocalizations.of(context)!.deleteTitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    OutlinedButton.icon(
                      onPressed: _deleteUserAccount,
                      icon: Icon(Icons.delete_rounded, color: Colors.red),
                      label: Text(
                        AppLocalizations.of(context)!.deleteButtonText,
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
