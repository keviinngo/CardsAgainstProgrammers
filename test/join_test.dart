import 'package:cap/screens/create.dart';
import 'package:cap/screens/game.dart';
import 'package:cap/screens/home.dart';
import 'package:cap/screens/join.dart';
import 'package:cap/screens/lobby.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('Home navigation tests', () {
    NavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    Future<Null> _buildHomeScreen(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          switch(settings.name) {
            case '/':
              return CupertinoPageRoute(builder: (_) {
                return JoinScreen();
              });
              break;
            case '/create':
              return CupertinoPageRoute(builder: (_) {
                return CreateScreen();
              });
              break;
            case '/lobby':
              return MaterialPageRoute(builder: (_) {
                return LobbyScreen(arguments: settings.arguments as Map<String, dynamic>,);
              });
            default:
              return CupertinoPageRoute(builder: (_) {
                return HomeScreen();
              });
              break;
          }
        },
        navigatorObservers: [mockObserver],
      ));
      await tester.pumpAndSettle();

      /// The tester.pumpWidget() call above just built our app widget
      /// and triggered the pushObserver method on the mockObserver once.
      verify(mockObserver.didPush(any, any));
    }

    Future<Null> _navigateToLobbyScreen(WidgetTester tester) async {
      /// Tap the button which should navigate to the details page.
      /// By calling tester.pumpAndSettle(), we ensure that all animations
      /// have completed before we continue further.
      await tester.tap(find.byKey(HomeScreen.navigateToJoinKey));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'when tapping "Join" button, should proceed to the lobby',
        (WidgetTester tester) async {
    });
  });
}
