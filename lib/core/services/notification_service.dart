import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const String _channelId = 'brivora_notifications';
  static const String _channelName = 'Brivora';
  static const String _channelDescription =
      'Уведомления о задачах, дедлайнах и проектах';

  /// Инициализация сервиса уведомлений.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createAndroidChannel();

    _initialized = true;
  }

  /// Создание Android-канала.
  static Future<void> _createAndroidChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Запрос разрешения на уведомления.
  static Future<bool> requestPermissions() async {
    await initialize();

    bool granted = true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      granted = result ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      granted = result ?? granted;
    }

    return granted;
  }

  /// Показать уведомление сразу.
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Запланировать уведомление.
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await initialize();

    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    final now = tz.TZDateTime.now(tz.local);

    if (!scheduled.isAfter(now)) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Запланировать уведомление о дедлайне задачи.
  static Future<void> scheduleTaskDeadline({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
    String? projectId,
  }) async {
    await schedule(
      id: _taskNotificationId(taskId),
      title: 'Дедлайн задачи',
      body: 'Срок задачи «$taskTitle» истекает.',
      scheduledDate: deadline,
      payload: _buildPayload(
        type: 'task_deadline',
        taskId: taskId.toString(),
        projectId: projectId,
      ),
    );
  }

  /// Запланировать предварительное напоминание.
  static Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
    Duration reminderBefore = const Duration(hours: 1),
    String? projectId,
  }) async {
    final reminderTime = deadline.subtract(reminderBefore);

    if (!reminderTime.isAfter(DateTime.now())) {
      return;
    }

    await schedule(
      id: _taskReminderNotificationId(taskId),
      title: 'Скоро дедлайн',
      body:
          'До дедлайна задачи «$taskTitle» осталось '
          '${_formatDuration(reminderBefore)}.',
      scheduledDate: reminderTime,
      payload: _buildPayload(
        type: 'task_reminder',
        taskId: taskId.toString(),
        projectId: projectId,
      ),
    );
  }

  /// Отменить уведомления конкретной задачи.
  static Future<void> cancelTaskNotifications(int taskId) async {
    await initialize();

    await _notifications.cancel(id: _taskNotificationId(taskId));

    await _notifications.cancel(id: _taskReminderNotificationId(taskId));
  }

  /// Отменить уведомление по ID.
  static Future<void> cancel(int id) async {
    await initialize();

    await _notifications.cancel(id: id);
  }

  /// Отменить все уведомления.
  static Future<void> cancelAll() async {
    await initialize();

    await _notifications.cancelAll();
  }

  /// Получить список запланированных уведомлений.
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    await initialize();

    return _notifications.pendingNotificationRequests();
  }

  /// Запланировать уведомление о неактивности проекта.
  static Future<void> scheduleProjectInactiveReminder({
    required int projectId,
    required String projectName,
    required DateTime lastOpenedAt,
    int inactiveDays = 7,
  }) async {
    final notificationDate = lastOpenedAt.add(Duration(days: inactiveDays));

    if (!notificationDate.isAfter(DateTime.now())) {
      return;
    }

    await schedule(
      id: _projectInactiveNotificationId(projectId),
      title: 'Проект давно не открывался',
      body:
          'Вы не заходили в проект «$projectName» '
          'уже $inactiveDays дней.',
      scheduledDate: notificationDate,
      payload: _buildPayload(
        type: 'project_inactive',
        projectId: projectId.toString(),
      ),
    );
  }

  /// Отменить уведомление о неактивности проекта.
  static Future<void> cancelProjectInactiveReminder(int projectId) async {
    await initialize();

    await _notifications.cancel(id: _projectInactiveNotificationId(projectId));
  }

  /// Обработка нажатия на уведомление.
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    // Навигацию подключим следующим этапом.
    //
    // task_deadline    -> конкретная задача
    // task_reminder    -> конкретная задача
    // project_inactive -> конкретный проект
  }

  static int _taskNotificationId(int taskId) {
    return 100000 + taskId;
  }

  static int _taskReminderNotificationId(int taskId) {
    return 200000 + taskId;
  }

  static int _projectInactiveNotificationId(int projectId) {
    return 300000 + projectId;
  }

  static String _buildPayload({
    required String type,
    String? taskId,
    String? projectId,
  }) {
    final parts = <String>['type=$type'];

    if (taskId != null) {
      parts.add('taskId=$taskId');
    }

    if (projectId != null) {
      parts.add('projectId=$projectId');
    }

    return parts.join('&');
  }

  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} дн.';
    }

    if (duration.inHours > 0) {
      return '${duration.inHours} ч.';
    }

    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} мин.';
    }

    return 'несколько минут';
  }
}
