import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/model/user_repository.dart';
import 'package:flutter_auth/ui/pages/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class MockUserRepository extends Mock implements UserRepository {
  final MockFirebaseAuth auth;
  MockUserRepository({this.auth});
}
class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockFirebaseUser extends Mock implements FirebaseUser{}

void main() {
  MockFirebaseAuth _auth = MockFirebaseAuth();
  BehaviorSubject<MockFirebaseUser> _user = BehaviorSubject<MockFirebaseUser>();
  MockUserRepository _repo;
  _repo = MockUserRepository(auth: _auth);
  Widget _makeTestable(Widget child) {
    return ChangeNotifierProvider<UserRepository>.value(
      value: _repo,
      child: MaterialApp(
        home: child,
      ),
    );
  }
  var emailField = find.byKey(Key("email-field"));
  var passwordField = find.byKey(Key("password-field"));
  var signInButton = find.text("Sign In");

  group("login page test", (){
    when(_repo.signIn("test@testmail.com", "password")).thenAnswer((_) async {return true;  });
    testWidgets('email, password and button are found', (WidgetTester tester) async{
      await tester.pumpWidget(_makeTestable(LoginPage()));
      expect(emailField, findsOneWidget);
      expect(passwordField,findsOneWidget);
      expect(signInButton, findsOneWidget);
    });
    testWidgets("validates empty email and password", (WidgetTester tester) async{
      await tester.pumpWidget(_makeTestable(LoginPage()));
      await tester.tap(signInButton);
      await tester.pump();
      expect(find.text("Please Enter Email"),findsOneWidget);
      expect(find.text("Please Enter Password"),findsOneWidget);
    });

    testWidgets("calls sign in method when email and password is entered", (WidgetTester tester) async {
      await tester.pumpWidget(_makeTestable(LoginPage()));
      await tester.enterText(emailField, "test@testmail.com");
      await tester.enterText(passwordField, "password");
      await tester.tap(signInButton);
      await tester.pump();
      verify(_repo.signIn("test@testmail.com", "password")).called(1);
    });
  });
  


}