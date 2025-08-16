part of 'package:web_dex/main.dart';

final class AppBootstrapper {
  AppBootstrapper._();

  static AppBootstrapper get instance => _instance;

  static final _instance = AppBootstrapper._();

  bool _isInitialized = false;

  Future<void> ensureInitialized(KomodoDefiSdk kdfSdk, Mm2Api mm2Api) async {
    if (_isInitialized) return;

    // Register core services with GetIt
    _registerDependencies(kdfSdk, mm2Api);

    final timer = Stopwatch()..start();
    await logger.init();
    await initializeLogger(mm2Api);

    log('AppBootstrapper: Log initialized in ${timer.elapsedMilliseconds}ms');
    timer.reset();

    await _warmUpInitializers().awaitAll();
    log('AppBootstrapper: Warm-up initializers completed in ${timer.elapsedMilliseconds}ms');
    timer.stop();

    _isInitialized = true;
  }

  /// Register all dependencies with GetIt
  void _registerDependencies(KomodoDefiSdk kdfSdk, Mm2Api mm2Api) {
    // Register core services
    GetIt.I.registerSingleton<KomodoDefiSdk>(kdfSdk);
    GetIt.I.registerSingleton<Mm2Api>(mm2Api);
  }

  /// A list of futures that should be completed before the app starts
  /// ([runApp]) which do not depend on each other.
  List<Future<void>> _warmUpInitializers() {
    return [
      app_bloc_root.loadLibrary(),
      packageInformation.init(),
      EasyLocalization.ensureInitialized(),
      CexMarketData.ensureInitialized(),
      PlatformTuner.setWindowTitleAndSize(),
      _initializeSettings(),
      _initHive(isWeb: kIsWeb || kIsWasm, appFolder: appFolder).then(
        (_) => sparklineRepository.init(),
      ),
    ];
  }

  /// Initialize settings and register analytics
  Future<void> _initializeSettings() async {
    final stored = await SettingsRepository.loadStoredSettings();
    _storedSettings = stored;

    // Register the analytics repository with GetIt
    // This will make sure we have a singleton instance across the app
    FirebaseAnalyticsRepo.register(stored.analytics);

    log('AppBootstrapper: Analytics repository registered with GetIt');
    return;
  }
}

Future<void> _initHive({required bool isWeb, required String appFolder}) async {
  if (isWeb) {
    return Hive.initFlutter(appFolder);
  }

  final appDirectory = await getApplicationDocumentsDirectory();
  final path = p.join(appDirectory.path, appFolder);
  return Hive.init(path);
}

StoredSettings? _storedSettings;
