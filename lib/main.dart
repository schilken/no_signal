import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:no_signal/providers/auth.dart';
import 'package:no_signal/providers/user_data.dart';
import 'package:no_signal/themes.dart';

import 'pages/home/home_page.dart';
import 'pages/home/users_list_page.dart';
import 'pages/loading/loading_page.dart';
import 'pages/login/create_profile.dart';
import 'pages/login/login_page.dart';
import 'pages/login/welcome_page.dart';
import 'pages/settings/settings.dart';

Future<void> main() async {
  //  To ensure widgets are glued properly
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

// activate to monitor requests with Proxyman
//  HttpOverrides.global = ProxyHttpOverrides();

  ///  [ProviderScope] is necessary to access the all the providers
  runApp(const ProviderScope(child: MainApp()));
}

///  I used a [ConsumerStatefulWidget] so that I can use the [initState] method
///  to check if the user is logged in or not
///  and then decide the course of action
class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  Future<void> _init(WidgetRef ref) async {
    //  This is how you can access providers in stateful widgets
    final user = await ref.read(userProvider.future);
    if (user != null) {
      //  This is how you can modify the state of the providers
      // **Note:** This would be called only when user was already logged in.
      final userData = await ref.read(userDataClassProvider).getCurrentUser();
      ref
          .read(currentLoggedUserProvider.state).state = userData;

      ref.read(userLoggedInProvider.state).state = true;
    } else {
      ref.read(userLoggedInProvider.state).state = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _init(ref);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Signal',
      themeMode: ThemeMode.dark,
      darkTheme: NoSignalTheme.darkTheme(),
      theme: NoSignalTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
      routes: {
        LoginPage.routename: (context) => const LoginPage(),
        HomePage.routename: (context) => const HomePage(),
        CreateAccountPage.routeName: (context) => const CreateAccountPage(),
        UsersListPage.routeName: (context) => const UsersListPage(),
        SettingsScreen.routename: (context) => const SettingsScreen(),
      },
    );
  }
}

///   This is [AuthChecker] widget which is used to check if the user is logged in or not
///  since it depends on [State] we do not need to use navigator to route to widgets
///  it will automatically change according to the [State].
class AuthChecker extends ConsumerWidget {
  const AuthChecker({Key? key}) : super(key: key);

  ///  So here's the thing what we have done
  ///  if the [_isLoggedIn] is true, we will go to [HomePage]
  ///  if false we will go to [WelcomePage]
  /// and if the user is null we will show a [LoadingPage]
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(userLoggedInProvider.state).state;
    if (isLoggedIn == true) {
      return const HomePage(); // It's a simple basic screen showing the home page
    } else if (isLoggedIn == false) {
      return const WelcomePage(); // It's the intro screen we made
    }
    return const LoadingPage(); // It's a plain screen with a circular progress indicator in Center
  }
}

class ProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    const proxyUrl = '192.168.2.104:9090';
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..findProxy = (uri) {
        if (uri.host.contains('localhost')) {
          return 'DIRECT';
        }
        debugPrint('main_with_proxy URI: $uri  -> $proxyUrl\n');
        return 'PROXY $proxyUrl';
      };
  }
}
