import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imovies/pages/AuthPages/phone.dart';
import 'package:pinput/pinput.dart';

class MyOtp extends StatefulWidget {
  const MyOtp({super.key});

  @override
  State<MyOtp> createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    var code = "";
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            )),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 45, right: 45),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Image.asset('assets/logo.jpg', width: 150,height: 150,),
              SizedBox(
                height: 25,
              ),
              Text(
                'Phone Verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'We need to register your phone number before getting started !',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),

              Pinput(
                length: 6,
                // validator: (s) {
                //   return s == '2222' ? null : 'Pin is incorrect';
                // },
                // pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
                //onCompleted: (pin) => print(pin),
              ),
              SizedBox(
                height: 20,
              ),

              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (MyPhone.verify != null) {
  // Use MyPhone.verify as verificationId
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: MyPhone.verify!,
    smsCode: code,
  );

  try {
    // Sign in with the credential
    await auth.signInWithCredential(credential);
    Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
  } catch (e) {
    print('wrong OTP');
  }
} else {
  // Handle the case where verificationId is not available
  print('Verification ID is null. Handle this error.');
}

                    // try {
                    //   PhoneAuthCredential credential =
                    //       PhoneAuthProvider.credential(
                    //           verificationId: MyPhone.verify, smsCode: code);

                    //   // Sign the user in (or link) with the credential
                    //   await auth.signInWithCredential(credential);
                    //   Navigator.pushNamedAndRemoveUntil(
                    //       context, "home", (route) => false);
                    // } catch (e) {
                    //   print('wrong otp');
                    // }
                  },
                  child: Text('Verify phone number'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),

              Row(
                //since iski by defalt main axis alignment is center
                children: [
                  TextButton(
                      onPressed: () {
                        //taaki vapis se jb back kra otp vali screeen pr na jaaye
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'phone', (route) => false);
                      },
                      // child:Align(
                      //  alignment: Alignment.centerLeft,
                      child: Text(
                        'Edit Phone Number ?',
                        style: TextStyle(color: Colors.black),
                        // ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
