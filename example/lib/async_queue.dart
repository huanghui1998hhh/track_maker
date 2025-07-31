import 'dart:async';
import 'dart:collection';

class AsyncQueue {
  final Queue<_QueuedTask> _taskQueue = Queue<_QueuedTask>();

  bool _isProcessing = false;

  Future<T> add<T>(Future<T> Function() taskBuilder) {
    final completer = Completer<T>();

    _taskQueue.add(_QueuedTask<T>(taskBuilder, completer));
    _processQueue();

    return completer.future;
  }

  void _processQueue() {
    if (_isProcessing || _taskQueue.isEmpty) {
      return;
    }

    _isProcessing = true;
    _processNextTask();
  }

  void _processNextTask() {
    if (_taskQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    final task = _taskQueue.removeFirst();

    task.execute().whenComplete(() {
      _processNextTask();
    });
  }

  Future<void> waitForAll() {
    if (_taskQueue.isEmpty && !_isProcessing) {
      return Future.value();
    }

    final completer = Completer<void>();

    _taskQueue.add(_QueuedTask<void>(() async {}, completer));

    if (!_isProcessing) {
      _processQueue();
    }

    return completer.future;
  }

  int get length => _taskQueue.length;

  bool get isEmpty => _taskQueue.isEmpty && !_isProcessing;

  void clear() {
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      task.cancel();
    }
  }
}

class _QueuedTask<T> {
  _QueuedTask(this.taskBuilder, this.completer);
  final Future<T> Function() taskBuilder;
  final Completer<T> completer;

  Future<void> execute() async {
    try {
      final result = await taskBuilder();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (error, stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }
  }

  void cancel() {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('Task was cancelled'),
        StackTrace.current,
      );
    }
  }
}
