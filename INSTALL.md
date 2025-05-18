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
 root@vpshost:~/cheetahdex-wallet-web# flutter doctor -v
   Woah! You appear to be trying to run flutter as root.
   We strongly recommend running the flutter tool without superuser privileges.
  /
📎
[!] Flutter (Channel [user-branch], 3.22.3, on Ubuntu 22.04.5 LTS 5.15.0-25-generic, locale en_US.UTF-8)
    ! Flutter version 3.22.3 on channel [user-branch] at /root/flutter
      Currently on an unknown channel. Run `flutter channel` to switch to an official channel.
      If that doesn't fix the issue, reinstall Flutter by following instructions at https://flutter.dev/docs/get-started/insta
ll.
    ! Upstream repository unknown source is not a standard remote.
      Set environment variable "FLUTTER_GIT_URL" to unknown source to dismiss this error.
    • Framework revision b0850beeb2 (10 months ago), 2024-07-16 21:43:41 -0700
    • Engine revision 235db911ba
    • Dart version 3.4.4
    • DevTools version 2.34.3
    • If those were intentional, you can disregard the above warnings; however it is recommended to use "git" directly to perf
orm update checks and upgrades.

[✗] Android toolchain - develop for Android devices
    ✗ ANDROID_HOME = /root/android-studio
      but Android SDK not found at this location.

[✓] Chrome - develop for the web
    • Chrome at google-chrome

[✓] Linux toolchain - develop for Linux desktop
    • Ubuntu clang version 14.0.0-1ubuntu1.1
    • cmake version 3.22.1
    • ninja version 1.10.1
    • pkg-config version 0.29.2

[✓] Android Studio (version 2024.3)
    • Android Studio at /root/android-studio
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 21.0.5+-13047016-b750.29)

[✓] Connected device (2 available)
    • Linux (desktop) • linux  • linux-x64      • Ubuntu 22.04.5 LTS 5.15.0-25-generic
    • Chrome (web)    • chrome • web-javascript • Google Chrome 134.0.6998.165

[✓] Network resources
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

The above web compiling step includes downloading latest Komodo coins repo with 400+ coin logo images through github api.  Github imposed rate limit on raw file downloading recently so that above step will crash at middle of coins logo image downloading step.

## Step 2 - Workaround to bypass github downloading limit

Run below under repo folder to bypass the github downloading crash:
```
  git clone https://github.com/KomodoPlatform/coins
  cp coins/icons/*  assets/coin_icons/png/
  flutter build web --csp --no-web-resources-cdn
```
If above command runs successfully, the crash step will be skipped, it will say that coins has been updated, please re-compile web app again. Now re-compile:

```
  flutter build web --csp --no-web-resources-cdn
```

Now you should see the notice that web app has been compiled successfully at terminal. 

## Step 3 - Run Web App

run below:
```
  flutter run -d  web-server  --web-hostname  localhost --web-port=8888  --release
```

Now Cheetahdex Web Wallet should be running at "http://localhost:8888" web URL.  Change localhost into IP address or your hostname. 









