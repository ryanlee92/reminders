import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'reminder.dart';
import 'reminders_list.dart';
import 'reminders_method_channel.dart';

abstract class RemindersPlatform extends PlatformInterface {
  /// Constructs a RemindersPlatform.
  RemindersPlatform() : super(token: _token);

  static final Object _token = Object();

  static RemindersPlatform _instance = MethodChannelReminders();

  /// The default instance of [RemindersPlatform] to use.
  ///
  /// Defaults to [MethodChannelReminders].
  static RemindersPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RemindersPlatform] when
  /// they register themselves.
  static set instance(RemindersPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  
  Future<void> initialize() async {
    throw UnimplementedError('intialize() has not been implemented.');
  }

  Future<String?> getPlatformVersion() async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> hasAccess() async {
    throw UnimplementedError('hasAccess() has not been implemented.');
  }

  Future<RemList?> getDefaultList() async {
    throw UnimplementedError('getDefaultList() has not been implemented.');
  }

  Future<List<RemList>> getAllLists() async {
    throw UnimplementedError('getAllLists() has not been implemented.');
  }

  Future<List<Reminder>?> getReminders([String? id]) async {
    throw UnimplementedError('getReminders(String?) has not been implemented');
  }

  Future<Reminder> saveReminder(Reminder reminder) async {
    throw UnimplementedError('saveReminder(Reminder) has not been implemented');
  }

  Future<String?> deleteReminder(String? id) async {
    throw UnimplementedError('deleteReminder(String) has not been implemented');
  }
}
