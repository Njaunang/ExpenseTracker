import 'package:flutter/material.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/locale_provider.dart';
import 'package:lookup/screens/home_screen.dart';
import 'package:lookup/screens/signup_screen.dart';
import 'package:lookup/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        // Changed from login to signIn
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.loginSuccess,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.loginFailed,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // ← ADD THIS - Makes the screen scrollable
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      // width: 60,
                      // height: 60,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF264444).withValues(alpha: 0.1),
                      ),
                      child: Column(
                        children: [
                          Consumer<LocaleProvider>(
                            builder: (context, localProvider, child) {
                              return Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.en,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      localProvider.setLocale(Locale('en'));
                                    },
                                    icon:
                                        localProvider.locale.languageCode ==
                                            'en'
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.track_changes_rounded,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(
                      // width: 60,
                      // height: 60,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF264444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Consumer<LocaleProvider>(
                            builder: (context, localProvider, child) {
                              return Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.fr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      localProvider.setLocale(Locale('fr'));
                                    },
                                    icon:
                                        localProvider.locale.languageCode ==
                                            'fr'
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.signInToContinue,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40), // Increased from 20 to 40
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.emailOrUsername,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPassAndUsername;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.passwordLabelText,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30), // Increased from 20 to 30
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppLocalizations.of(context)!.signIn,
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dontHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.signUp),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Added bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
