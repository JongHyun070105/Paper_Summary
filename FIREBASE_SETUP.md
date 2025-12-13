# Firebase Google 로그인 설정 가이드

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: paper-reader)
4. Google Analytics 설정 (선택사항)

## 2. Android 앱 추가

1. Firebase 프로젝트에서 Android 아이콘 클릭
2. 패키지 이름: `com.example.flutter_paper_summary`
3. 앱 닉네임: `Paper Reader Android`
4. SHA-1 인증서 지문 추가 (디버그용):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. `google-services.json` 다운로드하여 `android/app/` 폴더에 복사

## 3. iOS 앱 추가

1. Firebase 프로젝트에서 iOS 아이콘 클릭
2. 번들 ID: `com.example.flutterPaperSummary`
3. 앱 닉네임: `Paper Reader iOS`
4. `GoogleService-Info.plist` 다운로드하여 `ios/Runner/` 폴더에 복사
5. Xcode에서 Runner 프로젝트에 파일 추가

## 4. Authentication 설정

1. Firebase Console에서 "Authentication" 선택
2. "Sign-in method" 탭 클릭
3. "Google" 제공업체 활성화
4. 프로젝트 지원 이메일 설정

## 5. 설정 파일 업데이트

### Android (`android/app/google-services.json`)

다운로드한 실제 파일로 교체

### iOS (`ios/Runner/GoogleService-Info.plist`)

다운로드한 실제 파일로 교체

### iOS Info.plist 업데이트

`ios/Runner/Info.plist`에서 `YOUR_REVERSED_CLIENT_ID`를 실제 값으로 교체:

```xml
<string>com.googleusercontent.apps.YOUR_ACTUAL_REVERSED_CLIENT_ID</string>
```

## 6. 의존성 설치

```bash
flutter pub get
```

## 7. 테스트

```bash
flutter run
```

## 주의사항

- 실제 기기에서 테스트 권장 (시뮬레이터에서는 Google 로그인이 제한될 수 있음)
- SHA-1 인증서는 릴리즈 빌드용으로도 별도 추가 필요
- iOS의 경우 Xcode에서 GoogleService-Info.plist가 올바르게 추가되었는지 확인

## 문제 해결

### Android

- `google-services.json` 파일이 `android/app/` 폴더에 있는지 확인
- minSdkVersion이 21 이상인지 확인

### iOS

- `GoogleService-Info.plist`가 Xcode 프로젝트에 추가되었는지 확인
- Bundle ID가 Firebase 설정과 일치하는지 확인
- URL Schemes가 올바르게 설정되었는지 확인
