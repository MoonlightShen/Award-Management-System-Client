import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cherrilog/cherrilog.dart';
import 'package:cherrilog/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:award_management_system/common/utils/shared_preferences_util.dart';

enum StatusCode {
  success(code: '1000');

  final String code;

  const StatusCode({required this.code});
}

class HttpRequestUtil {
  static const String _baseUrl = "http://192.168.199.1:8080";

  static Map<String, dynamic> _decode(Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  static Map<String, dynamic> decodeResponse(Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  static List<T> decodeIterable<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    Iterable dataIterable = data;
    return dataIterable.map((item) => fromJson(item)).toList();
  }

  static Future<T?> get<T>(
      String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'));

    if (response.statusCode == 200) {
      var result = _decode(response);
      if (result['code'] != '1000') {
        error('HttpRequest:GET $endpoint FAIL:${response.statusCode}');
        return null;
      }
      info('HttpRequest:GET $endpoint SUCCESS:${response.statusCode}');
      return fromJson(result['data']);
    } else {
      error('HttpRequest:GET $endpoint FAIL:${response.statusCode}');
      return null;
    }
  }

  static Future<List<T>?> getList<T>(
      String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'));

    if (response.statusCode == 200) {
      var result = _decode(response);
      if (result['code'] != '1000') {
        error('HttpRequest:GET $endpoint FAIL:${response.statusCode}');
        return null;
      }
      Iterable jsonResponse = result['data'];
      info('HttpRequest:GET $endpoint SUCCESS:${response.statusCode}');
      return jsonResponse.map((item) => fromJson(item)).toList();
    } else {
      error('HttpRequest:GET $endpoint FAIL:${response.statusCode}');
      return null;
    }
  }

  static Future<T?> post<T>(
      {required String endpoint,
      required Map<String, dynamic> parameters,
      required T Function(Map<String, dynamic> jsonData) fromJson,
      required void Function(String failCode) optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'token': await SharedPreferencesUtil.getString('token') ?? ''
        },
        body: json.encode(parameters),
      );

      if (response.statusCode == 200) {
        var result = decodeResponse(response);
        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return fromJson(result['data']);
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback(result['code']);
          return null;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        if (requestFailCallback != null) {
          requestFailCallback(response.statusCode);
        }
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      if (exceptionCallback != null) exceptionCallback(Exception(e));
      return null;
    }
  }

  static Future<T?> postWithFile<T>(
      {required String endpoint,
      required Map<String, dynamic> parameters,
      required T Function(Map<String, dynamic> jsonData) fromJson,
      required void Function(String failCode) optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback,
      required String filePath}) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'token': await SharedPreferencesUtil.getString('token') ?? ''
      });
      parameters.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      var fileToUpload = await http.MultipartFile.fromPath(
        'file',
        filePath,
      );
      request.files.add(fileToUpload);

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = decodeResponse(responseData);

        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return fromJson.call(result['data']);
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback.call(result['code']);
          return null;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        requestFailCallback?.call(response.statusCode);
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      exceptionCallback?.call(Exception(e));
      return null;
    }
  }

  static Future<Uint8List?> imagePost(
      {required String endpoint,
      Map<String, dynamic>? parameters,
      void Function(String failCode)? optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback}) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'token': await SharedPreferencesUtil.getString('token') ?? ''
      });
      parameters?.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = decodeResponse(responseData);
        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return base64Decode(result['data']['image']);
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback?.call(result['code']);
          return null;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        if (requestFailCallback != null) {
          requestFailCallback(response.statusCode);
        }
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      if (exceptionCallback != null) exceptionCallback(Exception(e));
      return null;
    }
  }

  static Future<bool> boolPostFile({
    required String endpoint,
    required String filePath,
    Map<String, dynamic>? parameters,
    void Function(String failCode)? optionFailCallback,
    void Function(int failCode)? requestFailCallback,
    void Function(Exception e)? exceptionCallback,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    request.headers.addAll({
      'token': await SharedPreferencesUtil.getString('token') ?? ''
    });
    parameters?.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    //   if (parameters != null) {
    //   request.fields['parameters'] = json.encode(parameters); // 将 JSON 数据作为一个字段发送
    // }

    var fileToUpload = await http.MultipartFile.fromPath(
      'file',
      filePath,
    );
    request.files.add(fileToUpload);

    var response = await request.send();

    try {
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = decodeResponse(responseData);

        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return true;
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback?.call(result['code']);
          return false;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        requestFailCallback?.call(response.statusCode);
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      exceptionCallback?.call(Exception(e));
      return false;
    }
  }

  static Future<bool> postForFile({
    required String endpoint,
    required String savePath,
    Map<String, dynamic>? parameters,
    void Function(String failCode)? optionFailCallback,
    void Function(int failCode)? requestFailCallback,
    void Function(Exception e)? exceptionCallback,
  }) async {
    final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'token': await SharedPreferencesUtil.getString('token') ?? ''
        },
        body: json.encode(parameters),
      );
    try {
      if (response.statusCode == 200) {
        var result = decodeResponse(response);

        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
           File file = File(savePath);
      await file.writeAsBytes(base64Decode(result['data']['file']));
          return true;
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback?.call(result['code']);
          return false;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        requestFailCallback?.call(response.statusCode);
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      exceptionCallback?.call(Exception(e));
      return false;
    }
  }

  static Future<bool> boolPost(
      {required String endpoint,
      Map<String, dynamic>? parameters,
      void Function(String failCode)? optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'token': await SharedPreferencesUtil.getString('token') ?? ''
      },
      body: json.encode(parameters),
    );

    try {
      if (response.statusCode == 200) {
        var result = decodeResponse(response);

        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return true;
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback?.call(result['code']);
          return false;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        requestFailCallback?.call(response.statusCode);
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      exceptionCallback?.call(Exception(e));
      return false;
    }
  }

  static Future<int?> totalNumberPost(
      {required String endpoint,
      required Map<String, dynamic> parameters,
      void Function(String failCode)? optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'token': await SharedPreferencesUtil.getString('token') ?? ''
        },
        body: json.encode(parameters),
      );

      if (response.statusCode == 200) {
        var result = decodeResponse(response);
        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:TOTAL NUMBER POST $endpoint');
          return result['data']['total'];
        } else {
          error(
              'HttpRequest FAIL with ${result['code']}:TOTAL NUMBER POST $endpoint');
          if (optionFailCallback != null) optionFailCallback(result['code']);
          return null;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:TOTAL NUMBER POST $endpoint');
        if (requestFailCallback != null) {
          requestFailCallback(response.statusCode);
        }
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:TOTAL NUMBER POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:TOTAL NUMBER POST $endpoint');
      }
      if (exceptionCallback != null) {
        exceptionCallback(Exception(e));
      }
      return null;
    }
  }

  static Future<List<T>?> postList<T>(
      {required String endpoint,
      required Map<String, dynamic> parameters,
      required T Function(Map<String, dynamic> jsonData) fromJson,
      required void Function(String failCode) optionFailCallback,
      void Function(int failCode)? requestFailCallback,
      void Function(Exception e)? exceptionCallback}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'token': await SharedPreferencesUtil.getString('token') ?? ''
        },
        body: json.encode(parameters),
      );

      if (response.statusCode == 200) {
        var result = decodeResponse(response);
        if (result['code'] == StatusCode.success.code) {
          info('HttpRequest SUCCESS:POST $endpoint');
          return result['data'].map<T>((item) => fromJson(item)).toList();
        } else {
          error('HttpRequest FAIL with ${result['code']}:POST $endpoint');
          optionFailCallback(result['code']);
          return null;
        }
      } else {
        error(
            'HttpRequest Exception with ${response.statusCode}:POST $endpoint');
        if (requestFailCallback != null) {
          requestFailCallback(response.statusCode);
        }
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        error('HttpRequest SocketException:POST $endpoint');
      }
      if (e is http.ClientException) {
        error('HttpRequest ClientException:POST $endpoint');
      }
      if (exceptionCallback != null) exceptionCallback(Exception(e));
      return null;
    }
  }
}
