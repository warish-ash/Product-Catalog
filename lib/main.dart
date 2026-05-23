import 'package:flutter/material.dart';
import 'package:product_catalog_manager/providers/product_provider.dart';
import 'package:product_catalog_manager/views/home/home_screen.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> ProductProvider())
      ],
      child: MaterialApp(
        title: "Product Catalog",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B2A6B),
          ),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
