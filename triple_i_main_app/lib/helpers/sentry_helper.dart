import 'package:sentry/sentry.dart';
import '../keys/api_keys.dart';

class SentryHelper {
  final dynamic exception;
  final dynamic stackTrace;

  SentryHelper({this.exception, this.stackTrace});

  Future<void> report() async {
    print(this.exception);
    print(this.stackTrace);

    await SentryClient(SentryOptions(dsn: kSentryDomainNameSystem))
        .captureException(exception, stackTrace: stackTrace);
  }
}
