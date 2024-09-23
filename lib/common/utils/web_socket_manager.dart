import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  late WebSocketChannel _channel;
  final String path;
  final String key;
  final String _base_url = 'ws://x.x.x.x:x';
  late final String _url;

  WebSocketManager({required this.onMessageCallback,required this.onDownCallback,required this.onErrorCallback, required this.key, required this.path}) {
    _url = _base_url + path;
    _connect();
  }

  final void Function(String message) onMessageCallback;
  final void Function() onDownCallback;
  final void Function(String error) onErrorCallback;

  //接收到消息
  onMessage(String message) {
    print('WebSocketManager Received $key : $message');
    onMessageCallback(message);
  }

  //重连
  onDown() {
    print('WebSocketManager WebSocket closed $key');
    _connect();
    onDownCallback();
  }

  //错误
  onError(String error) {
    print('WebSocketManager WebSocket error $key : $error');
    onErrorCallback(error);
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      print('WebSocketManager connected $key');

      _channel.stream.listen((message) => onMessage(message),
          onDone: () => onDown(), onError: (error) => onError(error));
    } catch (error) {
      print(error);
    }
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void close() {
    _channel.sink.close(status.goingAway);
  }
}
