// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

// omit './test_integration/tests/' part of path to testfile
final List<String> testsList = [
  'suspended_assets_test/suspended_assets_test.dart',
  'wallets_tests/wallets_tests.dart',
  'wallets_manager_tests/wallets_manager_tests.dart',
  'dex_tests/dex_tests.dart',
  'misc_tests/misc_tests.dart'
];

//app data path for mac and linux
const String macAppData = '/Library/Containers/com.komodo.komodowallet';
const String linuxAppData = '/.local/share/com.komodo.CheetahdexWallet';
const String windowsAppData = '\\AppData\\Roaming\\com.komodo';

const String suspendedCoin = 'KMD';
File? _configFile;

Future<void> main(List<String> args) async {
  // Configure CLI
  final parser = ArgParser();
  parser.addFlag('help',
      abbr: 'h', defaultsTo: false, help: 'Show help message and exit');
  parser.addOption('testToRun',
      abbr: 't',
      defaultsTo: '',
      help:
          'Specify a single testfile to run, if option is not used, all available tests will be run instead; option usage example: -t "design_tests/theme_test.dart"');
  parser.addOption('browserDimension',
      abbr: 'b',
      defaultsTo: '1024,1400',
      help: 'Set device window(screen) dimensions: height, width');
  parser.addOption('displayMode',
      abbr: 'd',
      defaultsTo: 'no-headless',
      help:
          'Set to "headless" for headless mode usage, defaults to no-headless');
  parser.addOption('device',
      abbr: 'D', defaultsTo: 'web-server', help: 'Set device to run tests on');
  parser.addOption('runMode',
      abbr: 'm',
      defaultsTo: 'profile',
      help: 'App build mode selectrion',
      allowed: ['release', 'debug', 'profile']);
  parser.addOption('browser-name',
      abbr: 'n',
      defaultsTo: 'chrome',
      help: 'Set browser to run tests on',
      allowed: ['chrome', 'safari', 'firefox', 'edge']);
  final ArgResults runArguments = parser.parse(args);
  final String testToRunArg = runArguments['testToRun'];
  final String browserDimensionArg = runArguments['browserDimension'];
  final String displayArg = runArguments['displayMode'];
  final String deviceArg = runArguments['device'];
  final String runModeArg = runArguments['runMode'];
  final bool runHelp = runArguments['help'];
  final String browserNameArg = runArguments['browser-name'];

  // Coins config setup for suspended_assets_test
  final Map<String, dynamic> originalConfig;
  _configFile = await _findCoinsConfigFile();
  originalConfig = _readConfig();

  // Show help message and exit
  if (runHelp) {
    print(parser.usage);
    exit(0);
  }

  // Run tests
  if (testToRunArg.isNotEmpty) {
    await _runTest(testToRunArg, browserDimensionArg, displayArg, deviceArg,
        runModeArg, browserNameArg, originalConfig);
  } else {
    for (final String test in testsList) {
      try {
        await _runTest(test, browserDimensionArg, displayArg, deviceArg,
            runModeArg, browserNameArg, originalConfig);
      } catch (e) {
        throw 'Caught error executing _runTest: ' + e.toString();
      }
    }
  }
}

Future<void> _runTest(
  String test,
  String browserDimentionFromArg,
  String displayStateFromArg,
  String deviceFromArg,
  String runModeFromArg,
  String browserNameArg,
  Map<String, dynamic> originalConfigPassed,
) async {
  print('Running test ' + test);

  if (test == 'suspended_assets_test/suspended_assets_test.dart') {
    if (_configFile == null) {
      throw 'Coins config file not found';
    } else {
      print('Temporarily breaking $suspendedCoin electrum config'
          ' in \'${_configFile!.path}\' to test suspended state.');
    }
    _breakConfig(originalConfigPassed);
  }

  print('Starting process for test: ' + test);

  ProcessResult result;
  try {
    if (deviceFromArg == 'web-server') {
      //Run integration tests for web app
      result = await Process.run(
        'flutter',
        [
          'drive',
          '--dart-define=testing_mode=true',
          '--driver=test_driver/integration_test.dart',
          '--target=test_integration/tests/' + test,
          '-d',
          deviceFromArg,
          '--browser-dimension',
          browserDimentionFromArg,
          '--' + displayStateFromArg,
          '--' + runModeFromArg,
          '--browser-name',
          browserNameArg
        ],
        runInShell: true,
      );
    } else {
      //Clear app data before tests for Desktop native app
      _clearNativeAppsData();

      //Run integration tests for native apps (Linux, MacOS, Windows, iOS, Android)
      result = await Process.run(
        'flutter',
        [
          'drive',
          '--dart-define=testing_mode=true',
          '--driver=test_driver/integration_test.dart',
          '--target=test_integration/tests/' + test,
          '-d',
          deviceFromArg,
          '--' + runModeFromArg
        ],
        runInShell: true,
      );
    }
  } catch (e) {
    if (test == 'suspended_assets_test/suspended_assets_test.dart') {
      _restoreConfig(originalConfigPassed);
      print('Restored original coins configuration file.');
    }
    throw 'Error running flutter drive Process: ' + e.toString();
  }

  stdout.write(result.stdout);
  if (test == 'suspended_assets_test/suspended_assets_test.dart') {
    _restoreConfig(originalConfigPassed);
    print('Restored original coins configuration file.');
  }
  // Flutter drive can return failed test results just as stdout message,
  // we need to parse this message and detect test failure manually
  if (result.stdout.toString().contains('failure')) {
    throw ProcessException('flutter', ['test ' + test],
        'Failure details are in chromedriver output.\n', -1);
  }
  print('\n---\n');
}

Map<String, dynamic> _readConfig() {
  Map<String, dynamic> json;

  try {
    final String jsonStr = _configFile!.readAsStringSync();
    json = jsonDecode(jsonStr);
  } catch (e) {
    print('Unable to load json from ${_configFile!.path}:\n$e');
    rethrow;
  }

  return json;
}

void _writeConfig(Map<String, dynamic> config) {
  final String spaces = ' ' * 4;
  final JsonEncoder encoder = JsonEncoder.withIndent(spaces);

  _configFile!.writeAsStringSync(encoder.convert(config));
}

void _breakConfig(Map<String, dynamic> config) {
  final Map<String, dynamic> broken = jsonDecode(jsonEncode(config));
  broken[suspendedCoin]['electrum'] = [
    {
      'url': 'broken.e1ectrum.net:10063',
      'ws_url': 'broken.e1ectrum.net:30063',
    }
  ];

  _writeConfig(broken);
}

void _restoreConfig(Map<String, dynamic> originalConfig) {
  _writeConfig(originalConfig);
}

Future<File?> _findCoinsConfigFile() async {
  final config = File('assets/config/coins_config.json');

  if (!config.existsSync()) {
    throw Exception('Coins config file not found at ${config.path}');
  }

  return config;
}

void _clearNativeAppsData() async {
  ProcessResult deleteResult;
  if (Platform.isWindows) {
    var homeDir = Platform.environment['UserProfile'];
    if (await Directory('$homeDir$windowsAppData').exists()) {
      deleteResult = await Process.run(
        'rmdir',
        ['/s', '/q', '$homeDir$windowsAppData'],
        runInShell: true,
      );
      if (deleteResult.exitCode == 0) {
        print('Windows App data removed successfully.');
      } else {
        print(
            'Failed to remove Windows app data. Error: ${deleteResult.stderr}');
      }
    } else {
      print("No need clean windows app data");
    }
  } else if (Platform.isLinux) {
    var homeDir = Platform.environment['HOME'];
    deleteResult = await Process.run(
      'rm',
      ['-rf', '$homeDir$linuxAppData'],
      runInShell: true,
    );
    if (deleteResult.exitCode == 0) {
      print('Linux App data removed successfully.');
    } else {
      print('Failed to remove Linux app data. Error: ${deleteResult.stderr}');
    }
  } else if (Platform.isMacOS) {
    var homeDir = Platform.environment['HOME'];
    deleteResult = await Process.run(
      'rm',
      ['-rf', '$homeDir$macAppData'],
      runInShell: true,
    );
    if (deleteResult.exitCode == 0) {
      print('MacOS App data removed successfully.');
    } else {
      print('Failed to remove MacOS app data. Error: ${deleteResult.stderr}');
    }
  }
}
