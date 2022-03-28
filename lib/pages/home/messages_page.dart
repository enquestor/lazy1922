import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/utils.dart';

final _reversedRecordsWithDatesProvider = Provider<List>((ref) {
  final reversedRecords = ref.watch(recordsProvider).reversed.toList();
  if (reversedRecords.isEmpty) {
    return [];
  }
  final reversedRecordsWithDates = [];
  DateTime? previousDate = date(reversedRecords.first.time);
  for (final record in reversedRecords) {
    final currentDate = date(record.time);
    if (currentDate != previousDate) {
      reversedRecordsWithDates.add(previousDate);
      previousDate = currentDate;
    }
    reversedRecordsWithDates.add(record);
  }
  reversedRecordsWithDates.add(date(reversedRecords.last.time));
  return reversedRecordsWithDates;
});

class MessagesPage extends ConsumerWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reversedRecordsWithDates = ref.watch(_reversedRecordsWithDatesProvider).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      reverse: true,
      itemCount: reversedRecordsWithDates.length,
      itemBuilder: (context, index) {
        final item = reversedRecordsWithDates[index];
        if (item is DateTime) {
          return _buildDate(context, item);
        } else if (item is Record) {
          return _buildRecord(context, item);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildDate(BuildContext context, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            DateFormat('EEEE, MMMM d').format(date),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  Widget _buildRecord(BuildContext context, Record record) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            DateFormat('h:m a').format(record.time),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Flexible(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(record.message, style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
