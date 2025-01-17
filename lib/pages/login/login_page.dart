import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_signal/api/auth/authentication.dart';
import 'package:no_signal/pages/home/home_page.dart';
import 'package:no_signal/pages/login/create_profile.dart';
import 'package:no_signal/providers/auth.dart';
import 'package:no_signal/themes.dart';

import '../../providers/user_data.dart';

//  Instead of creating Two Screens, I have Added both Login and Signup Screen in one Screen
//  Yes , I am Lazy , But I am not going to create two screens , I am going to create one screen

//  So for to monitor we are in which State we are i.e Login or signUp , I have used enums here
//  So I have created and Enum Status which contains two things Login and SignUp

//  and I have made a Global Variable type of Status, to use in LoginPage
// It's actually not recommended to use Global Variables , but I am using it here to make it simple

enum Status {
  login,
  signUp,
}

Status type = Status.login;

///  I have used [ConsumerStatefulWidget] to use [setState] functions in [LoginPage]
///  and declare the providers outside the [build] method
///  we could also have managed the state using Riverpod but I am not using it here
///  Remember Stateful widgets are made for a reason. If it would be bad
///  Flutter developers would not think of it in the first place.

class LoginPage extends ConsumerStatefulWidget {
  static const routename = '/LoginPage';
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  ///  [GlobalKey] is used to validate the [Form] and managing the state of the form
  final GlobalKey<FormState> _formKey = GlobalKey();

  ///  [TextEditingController] to get the data from the TextFields
  ///  we can also use Riverpod to manage the state of the TextFields
  ///  but again I am not using it here
  final _email = TextEditingController();
  final _password = TextEditingController();

  ///  A loading variable to show the loading animation when you a function is ongoing
  bool _isLoading = false;

  ///  This function is used to show a spinning Indicator when the function is ongoing
  void _loading() {
    if (mounted) {
    setState(() {
      _isLoading = !_isLoading;
    });
    } else {
      debugPrint('LoginPage no longer mounted');
    }
  }

  ///  This function is used to switch type - Login or SignUp
  void _switchType() {
    if (type == Status.signUp) {
      setState(() {
        type = Status.login;
      });
    } else {
      setState(() {
        type = Status.signUp;
      });
    }
    // log('$type');
  }

  /// This function show errors caught by api
  void _showError(String error) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error Occured'),
        content: Text(error),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"))
        ],
      ),
    );
  }

  //  Consuming a provider using watch method and storing it in a variable
  //  Now we will use this variable to access all the functions of the
  //  authentication
  //  I will show these providers in the upcoming gist

  late final Authentication auth = ref.watch(authProvider);
  //  The above provider is used to access authentication class


  Future<void> _loginWithGithub() async {
    _loading();
    try {
      await auth.loginWithOAuth(provider: 'github');
      final userData = await ref.read(userDataClassProvider).getCurrentUser();
      ref.read(currentLoggedUserProvider.state).state = userData;

      await Navigator.pushReplacementNamed(context, HomePage.routename);
    } on Exception catch (e) {
      debugPrint('_loginWithGithub exception: $e');
    }
    _loading(); // stop loader
  }

  //  Instead of creating a clutter on the onPressed Function
  //  I have decided to create a seperate function and pass them into the
  //  respective parameters.
  //  if you want you can write the exact code in the onPressed function
  //  it all depends on personal preference and code readability
  Future<void> _onPressedFunction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _loading();

    try {
      //
      if (type == Status.login) {
        //
        await auth.login(_email.text, _password.text);

        if (!mounted) return;

        final userData = await ref.read(userDataClassProvider).getCurrentUser();
        ref.read(currentLoggedUserProvider.state).state = userData;


        await Navigator.pushReplacementNamed(context, HomePage.routename);

        //
      } else {
        //
        await auth.signUp(_email.text, _password.text);

        if (!mounted) return;

        await Navigator.pushReplacementNamed(
          context,
          CreateAccountPage.routeName,
        );

        //
      }

      _loading(); // stop loader

      //
    } on AppwriteException catch (e) {
      //
      _showError(e.message!);

      _loading();
      //
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 30,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.only(top: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                              )),
                              const Spacer(flex: 1),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                    // color: Colors.white,
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(12)),
                                child: TextFormField(
                                  controller: _email,
                                  autocorrect: true,
                                  enableSuggestions: true,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email address',
                                    hintStyle: TextStyle(
                                        color: NoSignalTheme.lightBlueShade),
                                    icon: Icon(Icons.email_outlined,
                                        color: Colors.blue.shade700, size: 24),
                                    alignLabelWithHint: true,
                                    border: InputBorder.none,
                                  ),
                                  //  Our little validator to check things out
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        !value.contains('@')) {
                                      return 'Invalid email!';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(12)),
                                child: TextFormField(
                                  controller: _password,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 8) {
                                      return 'Password is too short!';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                        color: NoSignalTheme.lightBlueShade),
                                    icon: Icon(CupertinoIcons.lock_circle,
                                        color: Colors.blue.shade700, size: 24),
                                    alignLabelWithHint: true,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (type == Status.signUp)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.white),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: TextFormField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Confirm password',
                                      hintStyle: TextStyle(
                                          color: NoSignalTheme.lightBlueShade),
                                      icon: Icon(CupertinoIcons.lock_circle,
                                          color: Colors.blue.shade700,
                                          size: 24),
                                      alignLabelWithHint: true,
                                      border: InputBorder.none,
                                    ),
                                    validator: type == Status.signUp
                                        ? (value) {
                                            if (value != _password.text) {
                                              return 'Passwords do not match!';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  width: double.infinity,
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : MaterialButton(
                                          onPressed: _onPressedFunction,
                                          textColor: Colors.blue.shade700,
                                          textTheme: ButtonTextTheme.primary,
                                          minWidth: 100,
                                          padding: const EdgeInsets.all(18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            side: BorderSide(
                                                color: Colors.blue.shade700),
                                          ),
                                          child: Text(
                                            type == Status.login
                                                ? 'Log in'
                                                : 'Sign up',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  width: double.infinity,
                                  child: MaterialButton(
                                    onPressed: _loginWithGithub,
                                    color: Colors.blue.shade200,
                                    textColor: Colors.blue.shade700,
                                    textTheme: ButtonTextTheme.primary,
                                    minWidth: 100,
                                    padding: const EdgeInsets.all(18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(
                                          color: Colors.blue.shade700),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        //  A google icon here
                                        //  an External Package used here
                                        //  Font_awesome_flutter package used

                                        //  Also Google function not implemented
                                        //  I like to have it as a button and will
                                        //  add someday in the future
                                        FaIcon(FontAwesomeIcons.github),
                                        Text(
                                          ' Login with Github',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: type == Status.login
                                          ? 'Don\'t have an account? '
                                          : 'Already have an account? ',
                                      style: TextStyle(
                                          color: NoSignalTheme.whiteShade1),
                                      children: [
                                        TextSpan(
                                            text: type == Status.login
                                                ? 'Sign up now'
                                                : 'Log in',
                                            style: TextStyle(
                                                color: Colors.blue.shade700),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _switchType();
                                              })
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
