import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

late FirebaseAuth auth ;
final String email="omeraygun438@gmail.com";
final String password="1234abcd!?";
@override
  void initState() {
    // TODO: implement initState
    auth=FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if(user==null){
        debugPrint("user is logged out");
      }
      else{
        debugPrint("user is logged in email ${user.email} and email sti ${user.emailVerified}");
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          ElevatedButton(onPressed: () {
            emailPaswordenter();
          },
          style: ElevatedButton.styleFrom(primary: Colors.red),
           child: Text("Email/pasword/record")),
           ElevatedButton(onPressed: () {
             emailPaswordlogin();
           },
            child: Text("email/pasword/login")),
            ElevatedButton(onPressed: () {
             signoutUser();
           },
           style: ElevatedButton.styleFrom(primary: Colors.yellow),
            child: Text("logged out")),
            ElevatedButton(onPressed: () {
             deleteUser();
           },
           style: ElevatedButton.styleFrom(primary: Colors.purple),
            child: Text("delete user")),
            ElevatedButton(onPressed: () {
             changedPasword();
           },
           style: ElevatedButton.styleFrom(primary: Colors.green),
            child: Text("changed pasword")),
            ElevatedButton(onPressed: () {
              changedEmail();
            },style: ElevatedButton.styleFrom(primary: Colors.amber),
             child: Text("changed email")),
             ElevatedButton(onPressed: () {
               enterwithGoogle();
             }, child: Text("login with google"))
        ]),
       
      ),
      
    );
  }

  void emailPaswordenter() async{
    try{
      var userCreditinal= await auth.createUserWithEmailAndPassword(email: email, password: password);

      var myUser=userCreditinal.user;
      if(!myUser!.emailVerified){
       await myUser.sendEmailVerification();
      }
      else{
        debugPrint("user mail verifyd thnak you");
      }
     debugPrint(userCreditinal.toString());

    }
    catch(e){
      debugPrint(e.toString());
    }
  
  }
  
  void emailPaswordlogin() {
    try{
      var userCreditinal= auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint(userCreditinal.toString());
    }
    catch(e){
      debugPrint(e.toString());
    }
  }
  
  void signoutUser() async{
    var user=GoogleSignIn().currentUser;
    if(user != null){
      await GoogleSignIn().signOut();
    }
   
   await auth.signOut();
  }
  
  void deleteUser() async{
    if(auth.currentUser!=null){
      await auth.currentUser!.delete();
    }
    else{
      debugPrint("Like this user didnt exist");
    }
  }
  
  void changedPasword() async{
    try{
      await auth.currentUser!.updatePassword("1234567");
      await auth.signOut();
    } on FirebaseAuthException catch(e){
      if(e.code == "requires-recent-login"){
        var credential=EmailAuthProvider.credential(email: email, password: password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword("1234567");
        await auth.signOut();
      }
      
    }
    catch (e){
      debugPrint(e.toString());
    }
  }
  
  void changedEmail() async{
    try{
      await auth.currentUser!.updateEmail("newEmail@gmail.com");
      await auth.signOut();
    }on FirebaseAuthException catch(e){
      if(e.code=="requires-recent-login"){
        var credential=EmailAuthProvider.credential(email: email, password: password);
        auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updateEmail("newEmail@gmail.com");
        await auth.signOut();
      }
    }
    catch (e){
      debugPrint(e.toString());
    }
  }
  
  void enterwithGoogle() async{
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
   await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
