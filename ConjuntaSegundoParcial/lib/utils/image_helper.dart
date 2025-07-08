import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
