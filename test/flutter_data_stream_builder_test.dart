import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';

void main() {
  Widget _centeredText(String text) {
    return Center(child: Text(text, textDirection: TextDirection.ltr));
  }

  Widget textBuilder(BuildContext context, dynamic data) {
    return _centeredText(data.toString());
  }

  group('DataStreamBuilder', () {
    testWidgets('correctly renders loading, error and data from stream', (tester) async {
      final GlobalKey key = GlobalKey();
      final controller = StreamController<int>();

      await tester.pumpWidget(DataStreamBuilder<int>(
        key: key,
        stream: controller.stream,
        builder: textBuilder
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(1);
      controller.add(2);
      await tester.pump(Duration.zero);
      expect(find.text('2'), findsOneWidget);
      
      controller.add(3);
      await tester.pump(Duration.zero);
      expect(find.text('3'), findsOneWidget);

      controller.addError(Exception('bad'));
      await tester.pump(Duration.zero);
      expect(find.text('Exception: bad'), findsOneWidget);

      controller.addError('horrible');
      await tester.pump(Duration.zero);
      expect(find.text('Error: horrible'), findsOneWidget);

      controller.add(4);
      controller.close();
      await tester.pump(Duration.zero);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('correctly renders custom loading and error widgets', (tester) async {
      final GlobalKey key = GlobalKey();
      final controller = StreamController<List<int>>();

      await tester.pumpWidget(DataStreamBuilder<List<int>>(
        key: key,
        stream: controller.stream,
        loadingBuilder: (context) => _centeredText('Loading numbers...'),
        errorBuilder: (context, error) => _centeredText('Oops something went wrong!'),
        builder: textBuilder
      ));

      expect(find.text('Loading numbers...'), findsOneWidget);

      controller.add([1, 2]);
      await tester.pump(Duration.zero);
      expect(find.text('[1, 2]'), findsOneWidget);

      controller.addError(Exception('bad'));
      await tester.pump(Duration.zero);
      expect(find.text('Oops something went wrong!'), findsOneWidget);

      controller.close();
    });

    testWidgets('does not cause jank on initial data', (tester) async {

      final GlobalKey key = GlobalKey();
      final controller = StreamController<List<int>>();

      final loadingWidget = _centeredText('LOADING');
      final dataWidget = _centeredText('DATA');

      await tester.pumpWidget(DataStreamBuilder<List<int>>(
        key: key,
        stream: Stream.fromIterable([[1, 2], [2, 3]]),
        initialData: [0, 0],
        loadingBuilder: (context) => loadingWidget,
        builder: (_, __) => dataWidget
      ));

      expect(find.byWidget(loadingWidget), findsNothing);
      expect(find.byWidget(dataWidget), findsOneWidget);

      controller.close();
    });
  });

}