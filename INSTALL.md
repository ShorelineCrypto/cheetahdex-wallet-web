# Installation Guide for cheetahdex-wallet-web

For high level understanding of Cheetahdex Web Wallet  that this code base forked from, please checkout Komodo developer guide on README front page.

Cheetahdex Web Wallet pretty much preserved all the features in the open sourced Komodo Web Wallet app, with DEX enabled and some logo/name changes.

## Hardware Requirement - X86_64 Linux server at home or at cloud VPS

The whole package was tested successfully in linux (ubuntu 22.04) on x64 hardware. Cheetahdex Web Wallet app does not use
lots of disk space, nor CPU resources so that any reasonable home PC linux or linux on cloud VPS should work fine.

## Dependency Requirement - flutter and android-studio
Cheetahdex Web Wallet app is flutter based app.  You can compile and run self-hosted web app in Ubuntu 22.04 easily by meeting flutter and android-studio 
requirement below. Check out Komodo Developer Guide on README for details.
- Install latest version of android studio.  For easily navigate and install proper features of android-studio, a x-windows GUI on Ubuntu is recommended.
- Install flutter on proper version under your home directory.  Too new or too old version of flutter won't compile this release.

Finally, check dependency with below command:
```commandline
  flutter doctor -v
```

ShorelineCrypto production web app was compiled successfully under below dependency versions in Ubuntu 22.04:
```
 [!] Flutter (Channel [user-branch], 3.32.7, on Ubuntu 22.04.5 LTS 6.8.0-65-generic, locale en_US.UTF-8) [88ms]
    ! Flutter version 3.32.7 on channel [user-branch] at /home/hlu/flutter
      Currently on an unknown channel. Run `flutter channel` to switch to an official channel.
      If that doesn't fix the issue, reinstall Flutter by following instructions at https://flutter.dev/setup.
    ! Upstream repository unknown source is not a standard remote.
      Set environment variable "FLUTTER_GIT_URL" to unknown source to dismiss this error.
    • Framework revision d7b523b356 (4 weeks ago), 2025-07-15 17:03:46 -0700
    • Engine revision 39d6d6e699
    • Dart version 3.8.1
    • DevTools version 2.45.1
    • If those were intentional, you can disregard the above warnings; however it is recommended to use "git" directly to perform update checks and upgrades.

[!] Android toolchain - develop for Android devices (Android SDK version 29.0.3) [156ms]
    • Android SDK at /usr/lib/android-sdk
    ✗ cmdline-tools component is missing.
      Try installing or updating Android Studio.
      Alternatively, download the tools from https://developer.android.com/studio#command-line-tools-only and make sure to set the ANDROID_HOME environment variable.
      See https://developer.android.com/studio/command-line for more details.
    ✗ Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/to/linux-android-setup for more details.

[✓] Chrome - develop for the web [30ms]
    • Chrome at google-chrome

[✓] Linux toolchain - develop for Linux desktop [541ms]
    • Ubuntu clang version 14.0.0-1ubuntu1.1
    • cmake version 3.22.1
    • ninja version 1.10.1
    • pkg-config version 0.29.2
    • GL_EXT_framebuffer_blit: no
    • GL_EXT_texture_format_BGRA8888: no

[✓] Android Studio (version 2024.3) [25ms]
    • Android Studio at /home/hlu/android-studio
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 21.0.5+-12932927-b750.29)

[✓] Connected device (2 available) [3.2s]
    • Linux (desktop) • linux  • linux-x64      • Ubuntu 22.04.5 LTS 6.8.0-65-generic
    • Chrome (web)    • chrome • web-javascript • Google Chrome 139.0.7258.66

[✓] Network resources [496ms]
    • All expected network resources are available.

! Doctor found issues in 2 categories.

```


## Step 1 - compile cheetahdex-wallet-web

To compile your self-hosted web app, run below

```
  git clone https://github.com/ShorelineCrypto/cheetahdex-wallet-web.git
  cd cheetahdex-wallet-web && git checkout cheetahdex
  flutter build web --csp --no-web-resources-cdn
```

If above command runs successfully, it will say that coins has been updated, please re-compile web app again. Now re-compile:

```
  flutter build web --csp --no-web-resources-cdn
```

Now you should see the notice that web app has been compiled successfully at terminal. 

## Step 2 - Run Web App

run below:
```
  flutter run -d  web-server  --web-hostname  localhost --web-port=8888  --release
```

Now Cheetahdex Web Wallet should be running at "http://localhost:8888" web URL.  This web URL can only be accessed from same host machine that web app runs on. 

## Step 3 - Set up https with certbot/nginx

The new web version of Komodo Wallet imposed security enhancement feature that can only run through localhost host. Cheetahdex Web Wallet removed geo blocker restriction of komodo web wallet, however, this localhost restriction stays.

The setup of https redirection to full host name with certbot/nginx can follow similar method of electrumx WSS/SSL setup as in https://komodoplatform.com/en/docs/komodo/setup-electrumx-server/ 

For example, using Ubuntu 20.04 and NGINX:

```
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
```

Will create a cert file and key file, and update your nginx `sites-enabled` config.









