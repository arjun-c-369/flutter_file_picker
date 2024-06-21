import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:zktor/main.dart';
import 'package:zktor/post_screens/selfie_camera_screen.dart';
import 'package:zktor/splash/splash_screen.dart';
import 'package:zktor/util/common_files/all_text_style.dart';
import 'package:flutter/material.dart';




final MethodChannel _channel = MethodChannel(
  'miguelruivo.flutter.plugins.filepicker',
  Platform.isLinux || Platform.isWindows || Platform.isMacOS
      ? const JSONMethodCodec()
      : const StandardMethodCodec(),
);

const EventChannel _eventChannel =
    EventChannel('miguelruivo.flutter.plugins.filepickerevent');

/// An implementation of [FilePicker] that uses method channels.
class FilePickerIO extends FilePicker {
  static const String _tag = 'MethodChannelFilePicker';
  static StreamSubscription? _eventSubscription;

  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileLoading,
    bool? allowCompression = true,
    bool allowMultiple = false,
    bool? withData = false,
    int compressionQuality = 30,
    bool? withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) =>
      _getPath(
        type,
        allowMultiple,
        allowCompression,
        allowedExtensions,
        onFileLoading,
        withData,
        withReadStream,
        compressionQuality,
      );

  @override
  Future<bool?> clearTemporaryFiles() async =>
      _channel.invokeMethod<bool>('clear');

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    try {
      return await _channel.invokeMethod('dir', {});
    } on PlatformException catch (ex) {
      if (ex.code == "unknown_path") {
        print(
            '[$_tag] Could not resolve directory path. Maybe it\'s a protected one or unsupported (such as Downloads folder). If you are on Android, make sure that you are on SDK 21 or above.');
      }
    }
    return null;
  }

  Future<FilePickerResult?> _getPath(
    FileType fileType,
    bool allowMultipleSelection,
    bool? allowCompression,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool? withData,
    bool? withReadStream,
    int? compressionQuality,
  ) async {
    final String type = fileType.name;
    if (type != 'custom' && (allowedExtensions?.isNotEmpty ?? false)) {
      throw ArgumentError.value(
        allowedExtensions,
        'allowedExtensions',
        'Custom extension filters are only allowed with FileType.custom. '
            'Remove the extension filter or change the FileType to FileType.custom.',
      );
    }
    try {
      _eventSubscription?.cancel();
      if (onFileLoading != null) {
        _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
              (data) => onFileLoading((data as bool)
                  ? FilePickerStatus.picking
                  : FilePickerStatus.done),
              onError: (error) => throw Exception(error),
            );
      }


      
      final context = navigatorKey.currentState!.overlay!.context;
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;

      var val;

      if((fileType != null && fileType == FileType.image) || (allowedExtensions != null && (allowedExtensions.contains('jpg') || allowedExtensions.contains('jpeg') || allowedExtensions.contains('png') || allowedExtensions.contains('webp')))){
        val = await showDialog(

          context: context,
          barrierDismissible: true,
          builder: (context) {
            bool loading2 = false;
            return StatefulBuilder(
              builder: (context, setState2) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 20,),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  width: 60,height: 5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      color: Colors.black
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.close,color: Colors.black))
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: langText("Select One", style:  zktorTextStyleBlack(context,0.048, FontWeight.w700,),),
                          ),
                          SingleChildScrollView(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          Navigator.pop(context,'continue');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                          child: Row(
                                              children: [

                                                Icon(Icons.photo, size: 32),

                                                SizedBox(width: 15,height:1),

                                                Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [

                                                      langText("Gallery", style:  zktorTextStyleBlack(context,0.045, FontWeight.w600,),),

                                                      SizedBox(height: 2,width:1),

                                                      langText("Choose from gallery", style:  zktorTextStyleBlack(context,0.038, FontWeight.w500,),)

                                                    ]
                                                )

                                              ]
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 7,width:1),

                                      InkWell(
                                        onTap: () async{
                                          List<File>? result = await Navigator.push(
                                              context, new MaterialPageRoute(builder: (context) => CameraScreen(onlySingle: allowMultipleSelection)));
                                          Navigator.pop(context,result);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                          child: Row(
                                              children: [

                                                Icon(Icons.camera_alt, size: 32),

                                                SizedBox(width: 15,height:1),

                                                Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [


                                                      langText("Camera", style:  zktorTextStyleBlack(context,0.045, FontWeight.w600,),),

                                                      SizedBox(height: 2,width:1),

                                                      langText("Capture from camera", style:  zktorTextStyleBlack(context,0.038, FontWeight.w500,),)


                                                    ]
                                                )

                                              ]
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }else{
        val ='continue';
      }

      List<Map>? result = [];

      if(val == null){
        return null;
      }else if(val is List<File>){
       for(int i = 0;i<val.length;i++){
         
          result.add(
            {"path": val[i].path,"size": 0,"name":''}
          );
       }
      }else{
        result = await _channel.invokeListMethod(type, {
        'allowMultipleSelection': allowMultipleSelection,
        'allowedExtensions': allowedExtensions,
        'allowCompression': allowCompression,
        'withData': withData,
        'compressionQuality': compressionQuality,
      });
      }

      if (result == null) {
        return null;
      }

      final List<PlatformFile> platformFiles = <PlatformFile>[];

      for (final Map platformFileMap in result) {
        platformFiles.add(
          PlatformFile.fromMap(
            platformFileMap,
            readStream: withReadStream!
                ? File(platformFileMap['path']).openRead()
                : null,
          ),
        );
      }

      return FilePickerResult(platformFiles);
    } on PlatformException catch (e) {
      print('[$_tag] Platform exception: $e');
      rethrow;
    } catch (e) {
      print(
          '[$_tag] Unsupported operation. Method not found. The exception thrown was: $e');
      rethrow;
    }
  }

  @override
  Future<String?> saveFile(
      {String? dialogTitle,
      String? fileName,
      String? initialDirectory,
      FileType type = FileType.any,
      List<String>? allowedExtensions,
      Uint8List? bytes,
      bool lockParentWindow = false}) {
    if (Platform.isIOS || Platform.isAndroid) {
      return _channel.invokeMethod("save", {
        "fileName": fileName,
        "fileType": type.name,
        "initialDirectory": initialDirectory,
        "allowedExtensions": allowedExtensions,
        "bytes": bytes,
      });
    }
    return super.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      bytes: bytes,
      lockParentWindow: lockParentWindow,
    );
  }
}
