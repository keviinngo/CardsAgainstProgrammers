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
                return HomeScreen();
              });
              break;
            case '/join':
              return CupertinoPageRoute(builder: (_) {
                return JoinScreen();
              });
              break;
            case '/create':
              return CupertinoPageRoute(builder: (_) {
                return CreateScreen();
              });
              break;
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

    Future<Null> _navigateToJoinScreen(WidgetTester tester) async {
      /// Tap the button which should navigate to the details page.
      /// By calling tester.pumpAndSettle(), we ensure that all animations
      /// have completed before we continue further.
      await tester.tap(find.byKey(HomeScreen.navigateToJoinKey));
      await tester.pumpAndSettle();
    }

    Future<Null> _navigateToCreateScreen(WidgetTester tester) async {
      await tester.tap(find.byKey(HomeScreen.navigateToCreateKey));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'when tapping "Join" button, should navigate to join screen',
        (WidgetTester tester) async {
      await _buildHomeScreen(tester);
      await _navigateToJoinScreen(tester);

      verify(mockObserver.didPush(any, any));

      expect(find.byType(JoinScreen), findsOneWidget);
    });

    testWidgets(
      'when tapping "Join" button, should navigate to create screen',
      (WidgetTester tester) async{
        await _buildHomeScreen(tester);
        await _navigateToCreateScreen(tester);
        
        verify(mockObserver.didPush(any, any));

        expect(find.byType(CreateScreen), findsOneWidget);
      });
  });
}
