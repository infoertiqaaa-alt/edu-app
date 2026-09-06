
import 'package:flutter/material.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/features/lessons/presentation/screens/lessons_list_screen.dart';
import 'package:mr/features/student/presentation/screens/qr_code_view.dart';

class Root extends StatefulWidget {
  const Root({super.key, this.selectScreen});
 static const String screenRoute = 'root';
 final int? selectScreen;
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
late PageController controller;
late List<Widget> screens;
late int currentScreen ;
@override
  void initState() {
    currentScreen = widget.selectScreen ?? 0;
    screens =[
      QrCodeView(),
      LessonsListScreen()
        ];
    controller = PageController(initialPage: currentScreen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
        ),
        bottomNavigationBar: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft:Radius.circular(20) ,topRight:Radius.circular(20) ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
            ),
          child: BottomNavigationBar(
              type:BottomNavigationBarType.fixed,
              unselectedItemColor: const Color(0xff9CA3AF),
                selectedItemColor: AppColors.primary,
                currentIndex: currentScreen,
                onTap: (index) {
                  setState(() {
                    currentScreen = index ;
                  });
                  controller.jumpToPage(currentScreen);
                },
              items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home_filled),label: 'الرئيسية'),
                  BottomNavigationBarItem(icon: Icon(Icons.book),label: 'الدروس'),
              ]
              ),
        ),
    );
  }
}

