import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/testList.dart';
class SecPage extends StatefulWidget {
  @override
  createState() => new SecPageState();
}

class SecPageState extends State<SecPage> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    ScreenUtil.getInstance().setSp(28);
    return new Scaffold(
      appBar: new AppBar(
        title:new Center(
          child: new Text('发现'),         
        )
      ),
      body: new Center(
        child: new HomeList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
