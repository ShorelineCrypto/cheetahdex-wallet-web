# Installing Flutter SDK

Cheetahdex Wallet requires a specific Flutter version to build and run. The required version can be seen
on [FLUTTER_VERSION.md](FLUTTER_VERSION.md).

While it should be possible to go a few bugfixes versions over that version without issues,
it's generally intended to use that exact version.

There are two main ways to get an older copy of Flutter.

The first way is by cloning the official repository and then pinning to an older version.

1. Clone Flutter with
   ```
   cd ~
   git clone https://github.com/flutter/flutter.git
   ```
2. [Pin Flutter version](FLUTTER_VERSION.md#pin-flutter-version)


The second way is via downloading the desired version from the SDK Archives.
Here are [Windows](https://docs.flutter.dev/release/archive?tab=windows), [Mac](https://docs.flutter.dev/release/archive?tab=macos)
and [Linux](https://docs.flutter.dev/release/archive?tab=linux) download links.
Remember to extract the file into a convenient place, such as `~/flutter`.

Choose the option that is more convenient for you at the time.

If you opt for the SDK Archive, you easily change to use the [Pin Flutter version](FLUTTER_VERSION.md#pin-flutter-version) later if you prefer.

Add the flutter binaries subfolder `flutter/bin` to your system PATH. This process differs for each OS:

For macOS:
   ```
   nano ~/.zshrc
   export PATH="$PATH:$HOME/flutter/bin"
   ```
For Linux:
   ```
   vim ~/.bashrc
   export PATH="$PATH:$HOME/flutter/bin"
   ```
For Windows, follow the instructions below (from [flutter.dev](https://docs.flutter.dev/get-started/install/windows#update-your-path))::

   - From the Start search bar, enter `env` and select **Edit environment variables for your account**.
   - Under **User variables** check if there is an entry called **Path**:
     - If the entry exists, append the full path to flutter\bin using ; as a separator from existing values.
     - If the entry doesn't exist, create a new user variable named Path with the full path to flutter\bin as its value.

You might need to logout and re-login (or source the shell configuration file, if applicable) to make changes apply.

On macOS and Linux it should also be possible to confirm it's been added to the PATH correctly by running `which flutter`.
