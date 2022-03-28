import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:simple_grouped_listview/simple_grouped_listview.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider);
    return GroupedListView.list(
      padding: const EdgeInsets.all(4),
      shrinkWrap: false,
      reverse: true,
      items: records.reversed.toList(),
      itemGrouper: (Record item) => DateTime(item.time.year, item.time.month, item.time.day),
      headerBuilder: (context, DateTime time) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          DateFormat('EEEE, MMMM d').format(time),
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      listItemBuilder: (context, _, __, Record record) => Row(
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
      ),
    );
  }
}
