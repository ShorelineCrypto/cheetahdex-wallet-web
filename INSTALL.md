# Installation Guide for Cheetahdex Wallet Web App and Android App 

For high level understanding of Cheetahdex Wallet  that this code base forked from, please checkout Komodo developer guide on README front page.

Cheetahdex Wallet pretty much preserved all the features in the open sourced Komodo Wallet app, with DEX enabled and some logo/name changes.

## Hardware Requirement - X86_64 Linux server at home or at cloud VPS

The whole package was tested successfully in linux (ubuntu 22.04) on x64 hardware. Cheetahdex Web Wallet app does not use
lots of disk space, nor CPU resources so that any reasonable home PC linux or linux on cloud VPS should work fine.

## Dependency Requirement for web/android wallet - flutter and android-studio
Cheetahdex Web/Android Wallet app is flutter based app.  You can compile your own android apk, or compile and run self-hosted web app in Ubuntu 22.04 easily by meeting flutter and android-studio 
requirement below. Check out Komodo Developer Guide on README for details.
- Install latest version of android studio.  For easily navigate and install proper features of android-studio, a x-windows GUI on Ubuntu is recommended.
- Install flutter on proper version under your home directory.  Too new or too old version of flutter won't compile this release.

Finally, check dependency with below command:
```commandline
  flutter doctor -v
```

ShorelineCrypto production web/android app was compiled successfully under below dependency versions in Ubuntu 22.04:
```
 [!] Flutter (Channel [user-branch], 3.41.4, on Ubuntu 22.04.5 LTS 6.8.0-106-generic, locale en_US.UTF-8) [94ms]
    ! Flutter version 3.41.4 on channel [user-branch] at /home/hlu/flutter
      Currently on an unknown channel. Run `flutter channel` to switch to an official channel.
      If that doesn't fix the issue, reinstall Flutter by following instructions at https://flutter.dev/setup.
    ! Upstream repository unknown source is not a standard remote.
      Set environment variable "FLUTTER_GIT_URL" to unknown source to dismiss this error.
    • Framework revision ff37bef603 (7 weeks ago), 2026-03-03 16:03:22 -0800
    • Engine revision e4b8dca3f1
    • Dart version 3.11.1
    • DevTools version 2.54.1
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, omit-legacy-version-file,
      enable-lldb-debugging, enable-uiscene-migration
    • If those were intentional, you can disregard the above warnings; however it is recommended to use "git" directly to perform update checks and upgrades.

[✓] Android toolchain - develop for Android devices (Android SDK version 36.0.0) [2.9s]
    • Android SDK at /home/hlu/Android/Sdk
    • Emulator version 36.1.9.0 (build_id 13823996) (CL:N/A)
    • Platform android-36, build-tools 36.0.0
    • ANDROID_HOME = /home/hlu/android-studio
    • Java binary at: /home/hlu/android-studio/jbr/bin/java
      This is the JDK bundled with the latest Android Studio installation on this machine.
      To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
    • Java version OpenJDK Runtime Environment (build 21.0.5+-12932927-b750.29)
    • All Android licenses accepted.

[✓] Chrome - develop for the web [22ms]
    • Chrome at google-chrome

[✓] Linux toolchain - develop for Linux desktop [536ms]
    • Ubuntu clang version 14.0.0-1ubuntu1.1
    • cmake version 3.22.1
    • ninja version 1.10.1
    • pkg-config version 0.29.2
    • GL_EXT_framebuffer_blit: no
    • GL_EXT_texture_format_BGRA8888: no

[✓] Connected device (2 available) [177ms]
    • Linux (desktop) • linux  • linux-x64      • Ubuntu 22.04.5 LTS 6.8.0-106-generic
    • Chrome (web)    • chrome • web-javascript • Google Chrome 146.0.7680.153

[✓] Network resources [301ms]
    • All expected network resources are available.

! Doctor found issues in 1 category.

```

## Cheetahdex Wallet Web App
### Step 1 - compile cheetahdex-wallet web app

To compile your self-hosted web app, run below

```
  git clone https://github.com/ShorelineCrypto/cheetahdex-wallet-web.git
  cd cheetahdex-wallet-web && git checkout cheetahdex
  git submodule update --init --recursive
  flutter build web --csp --no-web-resources-cdn --wasm
```

If above command runs successfully, it will say that coins has been updated, please re-compile web app again. Now re-compile:

```
  flutter build web --csp --no-web-resources-cdn --wasm
```

Now you should see the notice that web app has been compiled successfully at terminal. 

### Step 2 - Run Web App

run below:
```
  flutter run -d  web-server  --web-hostname  localhost --web-port=8888  --release
```

Now Cheetahdex Web Wallet should be running at "http://localhost:8888" web URL.  This web URL can only be accessed from same host machine that web app runs on. 

### Step 3 - Set up https with certbot/nginx

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

## Cheetahdex Wallet Android App
### Step 1 - compile cheetahdex-wallet android app

There are 3 ways to compile android apk installation file: github action CI/CD method, docker method and flutter build method. Here android apk release was obtained through flutter method.

To compile your own android app apk file, make sure your linux server (ubuntu 22.04) met the flutter/android studio dependency as shown above, then run below

```
  git clone https://github.com/ShorelineCrypto/cheetahdex-wallet-web.git
  cd cheetahdex-wallet-web && git checkout cheetahdex
  git submodule update --init --recursive
  flutter clean
  flutter pub get
  dart run flutter_launcher_icons
  flutter build apk
```

If above command runs successfully, it may say that coins has been updated, please re-compile android app again. Now re-compile:

```commandline
    flutter build apk
```

Now your android apk files will be built successfully under 'build' folder.  Transfer apk file into your android phone/pad,  install and run the android app for Cheetahdex Wallet.

### Step 2 - Trouble shoot Icon/Logo Failure

If step 1 failed with message like "duplicate error on color.xml bla bla", or the new icon/logo in your local branch does not show up fresh, you can clear graddle/kotlin cache with below command:

```commandline
  cd android/
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  dart run flutter_launcher_icons
  flutter build apk
```

## Cheetahdex Wallet Linux Desktop App
### Step 1 - compile cheetahdex-wallet Desktop Linux app

There are 3 ways to compile linux desktop binary file: github action CI/CD method, docker method and flutter build method. Here linux release was obtained through flutter method.

To compile your own linux release files, make sure your linux server (ubuntu 22.04) met the flutter/linux dependency as shown above, then run below

```
  git clone https://github.com/ShorelineCrypto/cheetahdex-wallet-web.git
  cd cheetahdex-wallet-web && git checkout cheetahdex
  git submodule update --init --recursive
  flutter clean
  flutter pub get
  flutter build linux
```

If above command runs successfully, it may say that coins has been updated and crash, please re-compile linux app again. Now re-compile:

```commandline
    flutter build linux
```

Now your linux binary release files will be built successfully under 'build/linux/x64/release/bundle' folder.  Rename this `bundle` folder name into proper linux folder with version, then move the whole folder into desired installation location such as below:

```commandline
mv build/linux/x64/release/bundle ~/cheetahdex-wallet_linux_unified_0.9.3.1

```

### Step 2 - Trouble shoot Linux Failure on kdf

You can launch the linux app from Linux Desktop by double clicking the binary file directly.  However, it is known that if you symbolic link the binary file into other location such as Desktop, an error of "kdf not found" will show up. 

You can also launch the linux wallet app on terminal with all the log printing out in details on terminal as below:
```commandline
  cd ~/cheetahdex-wallet_linux_unified_0.9.3.1
  ./CheetahdexWallet &
  
```



