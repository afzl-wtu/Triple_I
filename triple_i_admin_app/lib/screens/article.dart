import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import '../models/article.dart';

class Article extends StatefulWidget {
  @override
  _ArticleState createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  Language _language = Language.English;
  File _tsdqImage1;
  List<Asset> images = [];
  String _image;
  List<String> _images = [];
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final tsdqPicker = ImagePicker();

  final ref = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  Future getImage(int container) async {
    _tsdqImage1 =
        File((await tsdqPicker.getImage(source: ImageSource.gallery)).path);

    setState(() {});
  }

  void onSave() async {
    setState(() {
      _isLoading = true;
    });
    print(images.length);
    if (images.isEmpty) {
      try {
        if (_images.isEmpty &&
            _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _tsdqImage1 != null) {
          await uploadImage();
          await ref.collection('Articles').add({
            'title': _titleController.text,
            'imageUrl': _image,
            'images': [],
            'description': _descriptionController.text,
            'language': _language == Language.English ? 'English' : 'Hebrew',
            'timeStamp': DateTime.now()
          });
          Navigator.pop(context);
        } else
          throw Exception('Please Fill All Fields');
      } catch (error) {
        await _showError(error);
      }
    } else
      try {
        print('Before upload Images');
        if (images.isNotEmpty && _titleController.text.isNotEmpty) {
          await uploadImage();
          print('After Upload images');
          await ref.collection('Articles').add({
            'title': _titleController.text,
            'imageUrl': '',
            'images': _images,
            'language': _language == Language.English ? 'English' : 'Hebrew',
            'timeStamp': DateTime.now(),
            'description': ''
          });
          print('Before Navigator.pop');
          Navigator.pop(context);
        } else
          throw Exception('Please Fill All Fields');
      } catch (error) {
        await _showError(error);
      }
  }

  Future<void> _showError(error) async {
    return showDialog(
        context: context,
        builder: (_) {
          print('PP inshowDialog');
          return AlertDialog(
            title: Text(
              'OOPS...',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              )
            ],
          );
        });
  }

  Future<void> uploadImage() async {
    if (_tsdqImage1 != null) {
      print('FFFFFFFF');
      Reference reference = storageReference.child('Articles').child(
          '${_titleController.text} ${DateTime.now().toIso8601String()}.jpg');
      UploadTask uploadTask = reference.putFile(_tsdqImage1);

      TaskSnapshot downloadUrl = await uploadTask;
      String _url = await downloadUrl.ref.getDownloadURL();
      _image = _url;
      print('End of uploadImage first part');
    } else {
      print('Start of upload method');
      await Future.forEach(images, (element) async {
        Reference reference = storageReference
            .child('Articles')
            .child(_titleController.text)
            .child('${DateTime.now().toIso8601String()}.jpg');
        final imgData = await element.getByteData();
        UploadTask uploadTask = reference.putData(imgData.buffer.asUint8List());
        TaskSnapshot downloadUrl = await uploadTask;
        String _url = await downloadUrl.ref.getDownloadURL();
        _images.add(_url);
        print('End of upload Image method ${_images.length}');
      });
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print('PP: In loadAssets, Error Block: $e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  Widget buildGridView() {
    return Container(
      width: 300,
      height: 200,
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return AssetThumb(
            asset: asset,
            width: 100,
            height: 100,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    File abc;
    if (images.isNotEmpty) {
      abc = File(images[0].identifier);
      print(abc.path);
      //images[0].metadata.then((value) => print('${value.toString()}'));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Article'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff12711), Color(0xfff5af19)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom: 10,
                ),
                child: images.isNotEmpty
                    ? buildGridView()
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            labelText: 'Article',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
              ),
              Center(child: Text('OR')),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: ElevatedButton(
                  child: Text("Pick images"),
                  onPressed: loadAssets,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    images.isEmpty ? buildPhoto(1) : Container(),
                    Container(
                      child: DropdownButton(
                        value: _language,
                        iconSize: 50,
                        iconEnabledColor: Colors.black,
                        items: [Language.English, Language.Hebrew]
                            .map((e) => DropdownMenuItem(
                                  child:
                                      Text(e.index == 0 ? 'English' : 'Hebrew'),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            print(value);
                            _language = value;
                          });
                        },
                        hint: Text(
                          'Language',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120, right: 120, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      child: _isLoading
                          ? Text('Uploading...')
                          : Text(
                              'Upload',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                      onPressed: _isLoading ? () {} : onSave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPhoto(int container) {
    File cc;
    if (container == 1) cc = _tsdqImage1;

    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: cc == null
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: Icon(
                    Icons.camera,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    getImage(container);
                  },
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  cc,
                  fit: BoxFit.cover,
                ),
              ),
        height: 100,
        width: 100);
  }
}
