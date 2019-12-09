library flutter_data_stream_builder;

import 'package:flutter/material.dart';

typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T data);
typedef DataErrorWidgetBuilder = Widget Function(
    BuildContext context, dynamic error);

/// Widget that builds itself based on the latest
/// loading, error and data states from a [Stream].
///
/// {@tool sample}
///
/// This sample shows a [DataStreamBuilder] rendering a list of posts
/// provided by an underlying websocket connection.
///
///
/// ```dart
/// DataStreamBuilder<List<Post>>(
///   stream: Repository.of<Post>().findAll(),
///   builder: (context, List<Post> posts) => ListView(
///     children: posts.map((post) => ListTile(title: Text(post.body))).toList(),
///   )
/// )
/// ```
///
/// Loading and error state rendering can be supplied as follows:
///
/// ```dart
/// DataStreamBuilder<List<Post>>(
///   stream: Repository.of<Post>().findAll(),
///   loadingBuilder: (context) => Center(child: Text('Loading posts...')),
///   errorBuilder: (context, error) => PostErrorView(error),
///   builder: (context, List<Post> posts) => ListView(
///     children: posts.map((post) => ListTile(title: Text(post.body))).toList(),
///   )
/// )
/// ```
///
/// {@end-tool}
///
/// See also:
///
///  * [StreamBuilder]
class DataStreamBuilder<T> extends StreamBuilderBase<T, AsyncSnapshot<T>> {
  /// Creates a new [DataStreamBuilder] that builds itself based on the latest
  /// loading, error and data states from the specified [stream] and whose build
  /// strategies are given by [loadingBuilder], [errorBuilder] and [builder],
  /// respectively.
  ///
  /// Sensible defaults are provided for [loadingBuilder] and [errorBuilder].
  ///
  /// The [initialData] is used to create the initial snapshot.
  /// 
  /// The [stream] and [builder] must not be null.
  const DataStreamBuilder(
      {Key key,
      this.initialData,
      @required Stream<T> stream,
      @required this.builder,
      WidgetBuilder loadingBuilder,
      DataErrorWidgetBuilder errorBuilder})
      : assert(builder != null),
        this.loadingBuilder = loadingBuilder,
        this.errorBuilder = errorBuilder,
        super(key: key, stream: stream);

  /// The data that will be supplied to the builder in the first frame.
  final T initialData;

  /// The build strategy used by this builder to render the loading state.
  final WidgetBuilder loadingBuilder;

  /// The build strategy used by this builder to render the error state.
  final DataErrorWidgetBuilder errorBuilder;

  /// The build strategy used by this builder to render data.
  final DataWidgetBuilder<T> builder;

  @override
  AsyncSnapshot<T> initial() =>
      AsyncSnapshot<T>.withData(ConnectionState.none, initialData);

  @override
  AsyncSnapshot<T> afterConnected(current) =>
      current.inState(ConnectionState.waiting);

  @override
  AsyncSnapshot<T> afterData(_, T data) =>
      AsyncSnapshot<T>.withData(ConnectionState.active, data);

  @override
  AsyncSnapshot<T> afterError(_, Object error) =>
      AsyncSnapshot<T>.withError(ConnectionState.active, error);

  @override
  AsyncSnapshot<T> afterDone(AsyncSnapshot<T> current) => current.inState(ConnectionState.done);

  @override
  AsyncSnapshot<T> afterDisconnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.none);

  @override
  Widget build(BuildContext context, AsyncSnapshot<T> summary) {
    if (summary.hasError) return _getError(context, summary.error);
    if (summary.hasData) return builder(context, summary.data);
    return _getLoading(context);
  }

  Widget _getLoading(BuildContext context) {
    return loadingBuilder?.call(context) ??
        Center(child: CircularProgressIndicator());
  }

  Widget _getError(BuildContext context, dynamic error) {
    final _errorBuilder = errorBuilder ??
        (context, dynamic error) {
          error = error is Exception ? error.toString() : 'Error: $error';
          return Center(
              child: Text(
            error,
            textDirection: TextDirection.ltr,
            style: TextStyle(backgroundColor: Colors.red, color: Colors.white),
          ));
        };
    return _errorBuilder.call(context, error);
  }
}
