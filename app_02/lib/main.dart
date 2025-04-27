import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_02/userMS_API_v2/view/UserListScreen.dart';
import 'package:app_02/userMS_API_v2/view/LoginScreen.dart';
//
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quản lý người dùng',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const _AuthCheckWidget(),
//     );
//   }
// }
//
// // Widget riêng biệt để kiểm tra xác thực
// class _AuthCheckWidget extends StatelessWidget {
//   const _AuthCheckWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<SharedPreferences>(
//       future: SharedPreferences.getInstance(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//
//         if (!snapshot.hasData) {
//           return LoginScreen();
//         }
//
//         final prefs = snapshot.data!;
//         final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//         if (isLoggedIn) {
//           return UserListScreen(
//             onLogout: () async {
//               final BuildContext currentContext = context;
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.clear();
//               Navigator.of(currentContext).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => LoginScreen()),
//                     (Route<dynamic> route) => false,
//               );
//               print("Logout");
//             },
//           );
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
/////////////////////////////image trong flutter
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gộp Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('spiderman')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hàng hình ảnh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Image.asset('assets/images1.png')),
              Expanded(child: Image.asset('assets/images2.png')),
              Expanded(child: Image.asset('assets/images3.png')),
            ],
          ),
          const SizedBox(height: 20),
          // Nút chuyển màn hình
          ElevatedButton(
            child: const Text('Chuyển đến màn hình 2'),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecondScreen()),
              );
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kết quả: $result')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Màn hình 2')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Quay lại màn hình 1'),
          onPressed: () {
            Navigator.pop(context, 'Hello từ màn hình 2!');
          },
        ),
      ),
    );
  }
}