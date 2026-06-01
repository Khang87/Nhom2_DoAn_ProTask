import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/task_model.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mở cửa sổ chọn nhiều file (có giới hạn dung lượng < 10MB mỗi file)
  Future<List<File>> pickFiles({double maxMb = 10.0}) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        List<File> validFiles = [];
        for (var path in result.paths) {
          if (path != null) {
            File f = File(path);
            int sizeInBytes = await f.length();
            if (sizeInBytes / (1024 * 1024) <= maxMb) {
              validFiles.add(f);
            } else {
              print("Bỏ qua file ${f.path} vì vượt quá ${maxMb}MB");
            }
          }
        }
        return validFiles;
      }
    } catch (e) {
      print("Lỗi khi chọn file: $e");
    }
    return [];
  }

  // Upload raw file and return AttachmentModel
  Future<AttachmentModel?> uploadFile(String folderPath, File file) async {
    try {
      String fileName = file.path.split(Platform.pathSeparator).last;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('$folderPath/${timestamp}_$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return AttachmentModel(
        fileName: fileName,
        fileUrl: downloadUrl,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      print("Lỗi tải file: $e");
      return null;
    }
  }

  // Tải file lên Firebase Storage và đính kèm URL vào Task
  Future<void> uploadAndAttachToTask(String taskId, File file) async {
    try {
      String fileName = file.path.split(Platform.pathSeparator).last;
      Reference storageRef = _storage.ref().child('tasks/$taskId/$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      AttachmentModel newAttachment = AttachmentModel(
        fileName: fileName,
        fileUrl: downloadUrl,
        uploadedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'attachments': FieldValue.arrayUnion([newAttachment.toMap()])
      });

      print("Tải file và đính kèm thành công!");
    } catch (e) {
      print("Lỗi tải file: $e");
    }
  }
}
