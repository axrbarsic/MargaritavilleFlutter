import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/content/content_owner_ref.dart';

void main() {
  group('ContentOwnerRef', () {
    test('creates exactly one room owner', () {
      final owner = ContentOwnerRef.room('101');

      expect(owner.kind, ContentOwnerKind.room);
      expect(owner.roomNumber, '101');
      expect(owner.assignmentId, isNull);
      expect(owner.eventPayload, {'roomNumber': '101'});
    });

    test('creates exactly one assignment owner', () {
      final owner = ContentOwnerRef.assignment('assignment-1');

      expect(owner.kind, ContentOwnerKind.assignment);
      expect(owner.roomNumber, isNull);
      expect(owner.assignmentId, 'assignment-1');
      expect(owner.eventPayload, {'assignmentId': 'assignment-1'});
    });

    test('restores a valid nullable database owner', () {
      expect(
        ContentOwnerRef.fromNullable(roomNumber: '147'),
        ContentOwnerRef.room('147'),
      );
      expect(
        ContentOwnerRef.fromNullable(assignmentId: 'assignment-7'),
        ContentOwnerRef.assignment('assignment-7'),
      );
    });

    test('rejects missing, dual, and blank owners', () {
      expect(() => ContentOwnerRef.fromNullable(), throwsArgumentError);
      expect(
        () => ContentOwnerRef.fromNullable(
          roomNumber: '101',
          assignmentId: 'assignment-1',
        ),
        throwsArgumentError,
      );
      expect(
        () => ContentOwnerRef.fromNullable(roomNumber: '  '),
        throwsArgumentError,
      );
      expect(
        () => ContentOwnerRef.fromNullable(assignmentId: ''),
        throwsArgumentError,
      );
    });
  });
}
