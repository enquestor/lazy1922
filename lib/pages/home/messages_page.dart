import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/record_action.dart';
import 'package:lazy1922/providers/is_place_mode_provider.dart';
import 'package:lazy1922/providers/pending_message_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:lazy1922/widgets/dialog_list_tile.dart';
import 'package:lazy1922/widgets/edit_place_dialog.dart';

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

  final pendingMessage = ref.watch(pendingMessageProvider);
  if (pendingMessage != null) {
    reversedRecordsWithDates.add(pendingMessage);
  }
  return reversedRecordsWithDates;
});

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _sendPendingMessage();
    });
  }

  void _sendPendingMessage() async {
    // send pending message
    final pendingMessage = ref.read(pendingMessageProvider);
    final pendingMessageNotifier = ref.read(pendingMessageProvider.notifier);
    if (pendingMessage != null) {
      // send sms
      await sendSMS(pendingMessage.message);

      // add record
      final recordsNotifier = ref.read(recordsProvider.notifier);
      recordsNotifier.add(pendingMessage.copyWith(time: DateTime.now()));

      // clear pending message
      pendingMessageNotifier.state = null;

      // no need to get location if user isn't premium
      final user = ref.read(userProvider);
      if (!user.isPremium) {
        return;
      }

      // no needto get location if location is already available
      if (pendingMessage.isLocationAvailable) {
        return;
      }

      // redeem location
      try {
        final location = await getLocation();
        recordsNotifier.redeemLastLocation(location.latitude, location.longitude);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reversedRecordsWithDates = ref.watch(_reversedRecordsWithDatesProvider);
    return Scaffold(
      appBar: _buildAppBar(),
      body: reversedRecordsWithDates.isEmpty ? _buildNoMessageBody() : _buildMessagesList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isPlaceMode = ref.watch(isPlaceModeProvider);
    final isPlaceModeNotifier = ref.read(isPlaceModeProvider.notifier);
    return AppBar(
      title: const Text('1922'),
      actions: [
        IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color: isPlaceMode ? Theme.of(context).colorScheme.primary : null,
          ),
          splashRadius: 20,
          onPressed: () => isPlaceModeNotifier.state = !isPlaceModeNotifier.state,
        )
      ],
    );
  }

  Widget _buildNoMessageBody() {
    return Center(
      child: Icon(
        Icons.message_outlined,
        size: MediaQuery.of(context).size.width * 0.3,
        color: Theme.of(context).textTheme.caption!.color!.withOpacity(0.2),
      ),
    );
  }

  Widget _buildMessagesList() {
    final reversedRecordsWithDates = ref.watch(_reversedRecordsWithDatesProvider);
    final pendingMessage = ref.watch(pendingMessageProvider);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      reverse: true,
      itemCount: reversedRecordsWithDates.length,
      itemBuilder: (context, index) {
        final item = reversedRecordsWithDates[index];
        if (item is DateTime) {
          return _buildDate(item);
        } else if (item is Record) {
          return _buildRecord(item, pending: pendingMessage != null && index == 0);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildDate(DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            DateFormat('EEEE, MMMM d').format(date),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  Widget _buildRecord(Record record, {bool pending = false}) {
    final isPlaceMode = ref.watch(isPlaceModeProvider);
    final placeMap = ref.watch(placesMapProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: pending ? 0.5 : 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 8),
              child: Text(
                pending ? '${'sending'.tr()} ...' : DateFormat('h:mm a').format(record.time),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Flexible(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Container(
                  decoration: record.isLocationAvailable
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                        ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 8),
                        child: Text(
                          isPlaceMode && placeMap.containsKey(record.code) ? placeMap[record.code]!.name : record.message,
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16, color: record.isLocationAvailable ? Colors.white : null),
                        ),
                      ),
                      onLongPress: () => _onRecordLongPress(record),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRecordLongPress(Record record) async {
    final placeMap = ref.read(placesMapProvider);
    List<DialogListTile> children = [
      DialogListTile(
        title: Text(
          'delete_message'.tr(),
          style: const TextStyle(color: Colors.red),
        ),
        onTap: () => Navigator.of(context).pop(RecordAction.delete),
      ),
    ];
    // add option to add to favorites if reasonable
    if (record.isLocationAvailable && !placeMap.containsKey(record.code)) {
      children = [
        DialogListTile(
          title: Text('add_to_favorites'.tr()),
          onTap: () => Navigator.of(context).pop(RecordAction.addToFavorites),
        ),
        ...children,
      ];
    }

    final selection = await showDialog<RecordAction>(
      context: context,
      builder: (context) => SimpleDialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: children,
      ),
    );

    switch (selection) {
      case RecordAction.addToFavorites:
        showDialog(
          context: context,
          builder: (context) => EditPlaceDialog(
            isAdd: true,
            place: Place.fromRecord(record, ''),
            onConfirm: (place) {
              final placeNotifier = ref.read(placesProvider.notifier);
              placeNotifier.add(place);
            },
          ),
        );
        break;
      case RecordAction.delete:
        final recordsNotifier = ref.read(recordsProvider.notifier);
        recordsNotifier.removeRecord(record);
        break;
      case null:
        break;
    }
  }
}
