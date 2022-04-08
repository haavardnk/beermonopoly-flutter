import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/about_screen.dart';
import './providers/filter.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './helpers/api_helper.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final channel = const AndroidNotificationChannel(
    'olmonopolet',
    'Ølmonopolet Notifikasjoner',
    description:
        'Denne kanalen er brukt for å annonsere tilgjengelighet av nye Ølslipp og annen funksjonalitet.',
    importance: Importance.high,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 7,
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
  );

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> sendFcmToken(String apiToken) async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken!.isNotEmpty) {
      ApiHelper.updateFcmToken(fcmToken, apiToken);
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        backgroundColor: Colors.grey[100],
        iconTheme: IconThemeData(color: Colors.grey[800]),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        accentColor: Colors.pink,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Filter(),
          ),
          ChangeNotifierProxyProvider<Auth, Cart>(
            create: (ctx) => Cart(),
            update: (ctx, auth, previousCart) =>
                previousCart!..update(auth.apiToken),
          ),
        ],
        child: Consumer<Auth>(builder: (ctx, auth, _) {
          Provider.of<Filter>(ctx, listen: false).loadFilters();
          if (auth.isAuth) {
            sendFcmToken(auth.apiToken);
          }
          return MaterialApp(
            localizationsDelegates: [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            scrollBehavior: MyCustomScrollBehavior(),
            title: 'Ølmonopolet',
            theme: theme,
            darkTheme: darkTheme,
            home: RateMyAppBuilder(
              builder: (context) => auth.isAuthOrSkipLogin
                  ? const HomeScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const SplashScreen()
                              : const AuthScreen(),
                    ),
              onInitialized: (context, rateMyApp) {
                if (rateMyApp.shouldOpenDialog) {
                  rateMyApp.showStarRateDialog(
                    context,
                    title: 'Rate Ølmonopolet!',
                    message:
                        'Bruk et øyeblikk på å gi en rating til Ølmonopolet også, det hjelper veldig!',
                    actionsBuilder: (context, stars) {
                      return [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () async {
                            await rateMyApp.callEvent(
                                RateMyAppEventType.rateButtonPressed);
                            Navigator.pop<RateMyAppDialogButton>(
                                context, RateMyAppDialogButton.rate);
                          },
                        ),
                      ];
                    },
                    onDismissed: () => rateMyApp
                        .callEvent(RateMyAppEventType.laterButtonPressed),
                  );
                }
              },
            ),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              AboutScreen.routeName: (ctx) => const AboutScreen(),
            },
          );
        }),
      ),
    );
  }
}
