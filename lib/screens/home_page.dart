import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
      title: Text('Loan Tracker'),
    ),
    body: Column(
      children: [
      Center(
        child:ElevatedButton(
          onPressed: (){
          context.goNamed('/login' );
        }, 
      child: Text('home page')
      ) ,),
      Container(
        height: 100,
        width: 100,
        color: Theme.of(context).colorScheme.primary,

        child: Text('Card',
        style: TextStyle(color:  Theme.of(context).colorScheme.onPrimary,)
        ),
      ),
      TextField(
                obscureText: true, // For password input
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
              ),
      ]
    ),
    );
  }
}