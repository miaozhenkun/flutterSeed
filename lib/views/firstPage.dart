import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:manhua/util/CommonUtils.dart';
import 'package:manhua/util/redux/MkState.dart';
import 'package:manhua/views/TsPage.dart';
import 'package:manhua/views/XsDetail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class FirstPage extends StatefulWidget {
  @override
  createState() => new FirstPageState();
}

class FirstPageState extends State<FirstPage> {
  static const width = 80.0;
  static const height = 60.0;
  @override
  Widget build(BuildContext context) {
    return Material(child: new StoreBuilder<MkState>(builder: (context, store) {
      return new Scaffold(
          appBar: new AppBar(
              title: new Center(
            child: new Text('首页'),
          )),
          body: RotatedBox(
              quarterTurns: 4,
              // height: .0,
              child: Card(
                  child: new Column(children: [
                new ListTile(
                  title: new Text('唐诗',
                      style: new TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text('唐朝'),
                  leading: new Icon(
                    Icons.business,
                    color: Colors.blue[500],
                  ),
                  onTap: () => toTsPage(),
                ),
                new Divider(),
                new ListTile(
                  title: new Text('小说',
                      style: new TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text('小说在线阅读'),
                  leading: new Icon(
                    Icons.contact_phone,
                    color: Colors.blue[500],
                  ),
                  onTap: () => toXsPage(),
                ),
                new Divider(),
                new ListTile(
                  title: new Text('夜间模式点我',
                      style: new TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text('点我'),
                  leading: new Icon(
                    Icons.contact_mail,
                    color: Colors.blue[500],
                  ),
                  onTap: () => switchTheme(context, store),
                ),
                new Divider(),
                new ListTile(
                  title: new Text('下载文件测试',
                      style: new TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text('下载APK'),
                  leading: new Icon(
                    Icons.file_download,
                    color: Colors.blue[500],
                  ),
                  onTap: () => downLoad(context),
                ),
              ]))));
    }));
  }

  void toTsPage() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new TsPage()));
  }

  void toXsPage() {
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new XsDetailPage()));
  }

  //下载APK文件
  Future downLoad(context) async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    executeDownload();
  }

// 获取安装地址
  Future<String> get _apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  // 下载
  Future<void> executeDownload() async {
    final path = await _apkLocalPath;
    //下载
    final taskId = await FlutterDownloader.enqueue(
        url:
            'http://113.208.113.12:8777/VaccinationServer/download/software/vaccine.apk',
        savedDir: path,
        showNotification: true,
        openFileFromNotification: true);
    FlutterDownloader.registerCallback((id, status, progress) {
      // 当下载完成时，调用安装
      if (taskId == id && status == DownloadTaskStatus.complete) {
        _installApk();
      }
    });
  }

// 安装
  Future<Null> _installApk() async {
    // MethodChannel(项目名)
    const platform = const MethodChannel("疫苗接种");
    try {
      final path = await _apkLocalPath;
      // 调用app地址
      await platform.invokeMethod('install', {'path': path + '/vaccine.apk'});
    } on PlatformException catch (_) {}
  }

  //切换夜间模式
  void switchTheme(context, store) {
    var list = ['白天', '夜间'];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      //LocalStorage.save(Config.THEME_COLOR, index.toString());
    }, colorList: CommonUtils.getThemeListColor());
  }
}

class TestFlowDelegate extends FlowDelegate {
  EdgeInsets margin = EdgeInsets.zero;

  TestFlowDelegate({this.margin});
  @override
  void paintChildren(FlowPaintingContext context) {
    var x = margin.left;
    var y = margin.top;
    for (int i = 0; i < context.childCount; i++) {
      var w = context.getChildSize(i).width + x + margin.right;
      if (w < context.size.width) {
        context.paintChild(i,
            transform: new Matrix4.translationValues(x, y, 0.0));
        x = w + margin.left;
      } else {
        x = margin.left;
        y += context.getChildSize(i).height + margin.top + margin.bottom;
        context.paintChild(i,
            transform: new Matrix4.translationValues(x, y, 0.0));
        x += context.getChildSize(i).width + margin.left + margin.right;
      }
    }
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
