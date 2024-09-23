import 'package:cherrilog/cherrilog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class FileUtil {
  static Future<PlatformFile?> pickFile(
      {List<String>? allowedExtensions}) async {
    FilePickerResult? result;
    if (allowedExtensions == null) {
      result = await FilePicker.platform.pickFiles();
    } else {
      result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: allowedExtensions);
    }
    if (result != null) {
      info(
          'FilePick SUCCESS: ${result.files.single.path!} ${DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())}');
      return result.files.first;
    } else {
      warning(
          'FilePick TERMINATE: ${DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())}');
      return null;
    }
  }

  static Future<String?> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      info(
          'DirectoryPick SUCCESS: $selectedDirectory ${DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())}');
      return selectedDirectory;
    } else {
      warning(
          'DirectoryPick TERMINATE: ${DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())}');
      return null;
    }
  }

  static String transformFileSuitableSize(int size) {
    String unit = 'b';
    double suitableSize = 0.0;
    if (size >= 1024) {
      suitableSize = size / 1024.0;
      unit = 'kb';
    }
    if (suitableSize >= 1024) {
      suitableSize = suitableSize / 1024.0;
      unit = 'mb';
    }
    if (suitableSize >= 1024) {
      suitableSize = suitableSize / 1024.0;
      unit = 'gb';
    }
    return '${suitableSize.toStringAsFixed(2)}$unit';
  }
}
