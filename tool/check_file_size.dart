import 'dart:io';

const _lineLimit = 300;

Future<void> main() async {
  final oversized = <String, int>{};
  for (final root in [Directory('lib'), Directory('test')]) {
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !_isHandwrittenDart(entity.path)) continue;
      final lineCount = await entity.readAsLines().then(
        (lines) => lines.length,
      );
      if (lineCount > _lineLimit) oversized[entity.path] = lineCount;
    }
  }

  if (oversized.isEmpty) {
    stdout.writeln('File-size guard passed (limit: $_lineLimit lines).');
    return;
  }

  for (final entry in oversized.entries) {
    stderr.writeln(
      'ERROR: ${entry.key} has ${entry.value} lines (limit: $_lineLimit).',
    );
  }
  exitCode = 1;
}

bool _isHandwrittenDart(String path) {
  return path.endsWith('.dart') &&
      !path.endsWith('.g.dart') &&
      !path.endsWith('.freezed.dart');
}
