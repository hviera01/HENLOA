import 'package:flutter/widgets.dart';

import 'session.dart';

class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({super.key, required Session session, required super.child})
    : super(notifier: session);

  static Session of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No hay SessionScope en el árbol de widgets');
    return scope!.notifier!;
  }
}
