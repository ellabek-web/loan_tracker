import 'package:go_router/go_router.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/screens/group_body.dart';
import 'package:loan_tracker/screens/group_page.dart';
// import 'package:loan_tracker/screens/custom_drawer.dart';
// import 'package:loan_tracker/screens/group_body.dart';
import 'package:loan_tracker/screens/home_page.dart';
import 'package:loan_tracker/screens/login_page.dart';
import 'package:loan_tracker/screens/splash.dart';
import 'package:loan_tracker/screens/signUp_page.dart';


final GoRouter appRouter =GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',
    name: 'splash',
    builder: (context, state) =>  SplashScreen(),),

    GoRoute(path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),),
   
    GoRoute(path: '/home',
    name: 'home',
    builder: (context, state) => const HomePage(),),

   GoRoute(
  path: '/group',
  name: 'group',
  builder: (context, state) {
    final group = state.extra as Group;
    return GroupDetail(group: group);
  },
),
    

    GoRoute(path: '/SignUpPage',
    name: 'SignUpPage',
    builder: (context, state) => const SignUpPage(),),
    
    // GoRoute(path: '/customDrawer',
    // name: 'customDrawer',
    // builder: (context, state) => c onst CustomDrawer(),),

    GoRoute(path: '/groupBody',
    name: 'groupBody',
    builder: (context, state) => const GroupBody(),)

  ]
  );