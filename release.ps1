flutter pub run change_app_package_name:main com.valliyv.delniit_dictionary
flutter pub run flutter_launcher_name:main
flutter pub run flutter_launcher_icons
flutter build windows --no-sound-null-safety
Invoke-WebRequest "https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll" -OutFile "build/windows/runner/Release/sqlite3.dll"
flutter pub run msix:create --install-certificate false
