import 'dart:io';

void main() async {
  // avoid_print 규칙을 무시하는 주석을 추가
  final scriptFiles = await Directory('scripts')
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  for (final file in scriptFiles) {
    String content = await file.readAsString();

    // 파일 시작 부분에 ignore 주석이 없으면 추가
    if (!content.contains('// ignore_for_file: avoid_print')) {
      content = '// ignore_for_file: avoid_print\n$content';
      await file.writeAsString(content);
    }
  }
}
