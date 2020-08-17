import 'package:example/app/modules/tabs/modules/tab1/pages/page1/page1_page.dart';
import 'package:example/app/modules/tabs/modules/tab1/pages/page2/page2_bloc.dart';
import 'package:example/app/modules/tabs/modules/tab1/pages/page1/page1_bloc.dart';
import 'package:example/app/modules/tabs/modules/tab1/pages/page2/page2_page.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_page.dart';

import 'pages/page3/page3_page.dart';
import 'pages/page4/page4_page.dart';

class Tab1Module extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => Page2Bloc()),
        Bind((i) => Page1Bloc()),
        Bind((i) => Tab1Bloc()),
      ];

  @override
  List<Router> get routers => [
        Router(Modular.initialRoute, child: (_, args) => Tab1Page()),
        Router("/page1", child: (_, args) => Page1Page(), transition: TransitionType.rotate),
        Router("/page2", child: (_, args) => Page2Page(), transition: TransitionType.leftToRight),
        Router(
          '/page3',
          child: (_, args) => Page3Page(),
          transition: TransitionType.custom,
          customTransition: CustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              //Just First Animation
              return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.ease)).animate(animation),
                  child: child);

              // //Using secondaryAnimation
              // return SlideTransition(
              //   transformHitTests: false,
              //   position: Tween<Offset>(
              //     begin: const Offset(0.0, 1.0),
              //     end: Offset.zero,
              //   ).chain(CurveTween(curve: Curves.ease)).animate(animation),
              //   child: SlideTransition(
              //     transformHitTests: false,
              //     position: Tween<Offset>(
              //       begin: Offset.zero,
              //       end: const Offset(0.0, -1.0),
              //     ).chain(CurveTween(curve: Curves.ease)).animate(secondaryAnimation),
              //     child: child,
              //   ),
              // );
            },
          ),
        ),
        Router("/page4", child: (_, args) => Page4Page(), transition: TransitionType.rightToLeft),
      ];
}
