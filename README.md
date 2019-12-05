# DataStreamBuilder

![Pub](https://img.shields.io/pub/v/flutter_data_stream_builder?style=flat-square)

A pragmatic `StreamBuilder` with sensible defaults.

It uses three different builders:

  - `builder`: invoked only when stream data is ready (required as parameter)
  - `loadingBuilder`: invoked when waiting for data (not required, the library provides a default)
  - `errorBuilder`: invoked when an error is present in the stream (not required, the library provides a default)

## Usage

Using defaults for loading and error states:

```dart
DataStreamBuilder<List<Post>>(
  stream: Repository.of<Post>().findAll(),
  builder: (context, List<Post> posts) => ListView(
    children: posts.map((post) => ListTile(title: Text(post.body))).toList(),
  )
)
```

Custom loading and error widgets:

```dart
DataStreamBuilder<List<Post>>(
  stream: Repository.of<Post>().findAll(),
  loadingBuilder: (context) => Center(child: Text('Loading posts...')),
  errorBuilder: (context, error) => PostErrorView(error),
  builder: (context, List<Post> posts) => ListView(
    children: posts.map((post) => ListTile(title: Text(post.body))).toList(),
  )
)
```

See tests and the Example tab for a full example.