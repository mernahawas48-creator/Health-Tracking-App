import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:meditrack/themes/appcolors.dart';

class NotificationCenterPage extends StatefulWidget { const NotificationCenterPage({super.key}); @override State<NotificationCenterPage> createState() => _NotificationCenterPageState(); }
class _NotificationCenterPageState extends State<NotificationCenterPage> {
  bool _read = false;
  Future<void> _markAll() async { setState(() => _read = true); await (await SharedPreferences.getInstance()).setBool('notifications_read', true); }
  @override void initState(){super.initState(); SharedPreferences.getInstance().then((p){if(mounted)setState(()=>_read=p.getBool('notifications_read')??false);});}
  @override Widget build(BuildContext context) { final ar=AppStrings.of(context).isArabic; return Scaffold(appBar:AppBar(title:Text(ar?'التنبيهات':'Notifications'),actions:[TextButton(onPressed:_markAll,child:Text(ar?'تحديد الكل كمقروء':'Mark all read'))]),body:ListView(padding:const EdgeInsets.all(16),children:[Card(color:_read?Colors.white:const Color(0xffFFF2EC),child:ListTile(leading:const Icon(Icons.notifications_active_outlined,color:Appcolors.SecondaryOrange),title:Text(ar?'تذكيرات الأدوية':'Medication reminders'),subtitle:Text(ar?'تظهر تذكيرات الأدوية المجدولة هنا.':'Your scheduled medication reminders appear here.'),trailing:_read?null:const Icon(Icons.circle,size:10,color:Appcolors.SecondaryOrange),onTap:_markAll)),const SizedBox(height:12),Center(child:Text(ar?'ستظهر التذكيرات الجديدة هنا.':'New reminders will appear here.'))])); }
}
