import 'package:flutter/material.dart';
// 导入拍照和选照片插件
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 导入dio网络请求插件
import 'package:dio/dio.dart';
// 导入图片转base64位转换库
import 'dart:convert';

Dio dio = new Dio();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'flutter颜值检测大师'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // 用户通过摄像头或图片库选择的照片
  File _image;
  var _faceInfo;

  // 点击按钮，选择图片
  // 形参中的 source 为选取照片的方式，有两种，分别为：
  //    ImageSource.camera   从相机拍照并得到照片
  //    ImageSource.gallery  从本地相册选择照片
  void choosePic(source) async {
    // 得到选取的照片
    var image = await ImagePicker.pickImage(source: source);

    // 为数据赋值用的
    setState(() {
      // 将取到的照片存到_imge变量中
      _image = image;
    });
    print(_image); // 打印输出

    // 如果选取的照片为空，则不执行后续人脸检测的业务逻辑
    if (image == null) {
      return;
    }

    // 调用API获取颜值信息
    getFaceInfo();

    ;
  }

  // 调用API获取颜值信息
  void getFaceInfo() {
    getHttp();
  }

  // 通过 async 和 await 简化异步 API 调用方式
  void getHttp() async {
    // 发起 post 请求
    // 参数1：请求的URL地址【必选】
    // 参数2：通过请求体发送的数据【可选】
    // 参数3：请求配置项【可选】
    var params = {
      'grant_type': 'client_credentials；',
      'client_id': '2Ec88Zjogf1gN19Ku8AeVnOL',
      'client_secret': '26i6zmGuRlvEt6cmVYHkdWaqSofjGGO3'
    };
    var response = await dio.post(
        "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=2Ec88Zjogf1gN19Ku8AeVnOL&client_secret=26i6zmGuRlvEt6cmVYHkdWaqSofjGGO3",
        data: {},
        options: new Options());
    // https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials
    // &client_id=Va5yQRHlA4Fq5eR3LT0vuXV4
    // &client_secret=26i6zmGuRlvEt6cmVYHkdWaqSofjGGO3&

    // 打印服务器返回的数据
    print(response.data);

    var access_token = response.data['access_token'];
    // 将图片转为base64位格式字符串
    var bytesList = _image.readAsBytesSync();
    var base64Img = base64Encode(bytesList);
    // 调用颜值检测的API
    var params2 = {
      'image': base64Img, // 传递base64合适的图片
      "image_type": 'BASE64', // 发送到后台图片类型
      "face_field": 'age,beauty,expression,gender,glasses,emotion',
    };
    var faceInfoResult = await dio.post(
        "https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=" +
            access_token,
        data: params2,
        options: new Options(contentType: ContentType.json));
    print(faceInfoResult);

    if (faceInfoResult.data['error_msg'] == 'SUCCESS') {
      // 将人脸信息存储起来
      setState(() {
        _faceInfo = faceInfoResult.data['result']['face_list'][0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rendappbar(),
      body: rendbody(),
      floatingActionButton:
          rendfloatingActionButton(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 渲染头部appbar
  Widget rendappbar() {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
    );
  }

  // 渲染页面主体区域
  Widget rendbody() {
    if (_image == null) {
      return Center(
        child: Text('请选择照片'),
      );
    }
    return renderResult();
  }

  Widget renderResult() {
    if (_faceInfo == null) {
      return Text('');
    }
    return Stack(
      children: <Widget>[
        Image.file(
          _image, // 被渲染的图片
          height: double.infinity, // 图片高度撑满整个页面的高度
          fit: BoxFit.cover, // 图片的填充模式
        ),
        renderBox()
      ],
    );
  }

  Widget renderBox() {
    if (_faceInfo == null) {
      return Text('');
    }
    var sexMap = {'male': '男', 'female': '女'};
    var expressionmap = {'none:':'不笑','smile':'微笑','laugh':'大笑'};
    var glassesmap = {'none':'无眼镜','common':'普通眼镜','sun':'墨镜'};
    var emotionmap = {'angry':'愤怒','disgust':'厌恶','fear':'恐惧','happy':'开心','sad':'伤心','surprise':'惊讶','neutral':'情绪',};
    return Center(
        child: Container(
      width: 300,
      height: 220,
      decoration: BoxDecoration(
          // 背景颜色【半透明的白色】
          color: Colors.white54,
          // 圆角
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('年龄:${_faceInfo['age']} 岁'),
                Text('性别:${sexMap[_faceInfo['gender']['type']]}'),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('颜值:${_faceInfo['beauty']}'),
                Text('表情:${expressionmap[_faceInfo['expression']['type']]}'),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('眼镜:${glassesmap[_faceInfo['glasses']['type']]}'),
                Text('情绪:${emotionmap[_faceInfo['emotion']['type']]}'),
              ])
        ],
      ),
      // decoration: BoxDecoration(borderRadius: Border(5)),
    ));
  }

  // 渲染底部浮动按钮
  Widget rendfloatingActionButton() {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround, //分散对齐
      children: <Widget>[
        // 第一个浮动按钮（拍照）
        FloatingActionButton(
          onPressed: () {
            choosePic(ImageSource.camera);
          },
          tooltip: 'Increment',
          child: Icon(Icons.photo_camera),
        ),
        // 第二个浮动按钮（相册）
        FloatingActionButton(
          onPressed: () {
            choosePic(ImageSource.gallery);
          },
          tooltip: 'Increment',
          child: Icon(Icons.photo_library),
        )
      ],
    );
  }
}
