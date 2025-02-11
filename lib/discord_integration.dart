import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

//****************** Discord OAuth Config ***************//
const String discordClientId = '1336244782195802122';
const String discordClientSecret = 'hywaTbsRN2mYyqaci2t4HwcKqu29s34M';
const String redirectUri = "discordauth:";
const String callbackUrlScheme = 'discordauth';

//********** Generate Code Verifier and Challenge (FIXED) ************//
String generateCodeVerifier() {
  final Random random = Random.secure();
  final List<int> values = List<int>.generate(43, (i) => random.nextInt(256));
  return base64UrlEncode(values)
      .replaceAll('=', '')
      .replaceAll('+', '-')
      .replaceAll('/', '_');
}

String generateCodeChallenge(String codeVerifier) {
  final List<int> bytes = utf8.encode(codeVerifier);
  final Digest digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes)
      .replaceAll('=', '')
      .replaceAll('+', '-')
      .replaceAll('/', '_');
}

//************* Authenticate Function (Returns User Data) *************//
Future<Map<String, dynamic>?> authenticate() async {
  final String codeVerifier = generateCodeVerifier();
  final String codeChallenge = generateCodeChallenge(codeVerifier);

  print('Generated Code Verifier: $codeVerifier');
  print('Generated Code Challenge: $codeChallenge');

  final Uri authorizationUrl =
      Uri.https('discord.com', '/api/oauth2/authorize', {
    'response_type': 'code',
    'client_id': discordClientId,
    'scope': 'identify',
    'redirect_uri': redirectUri,
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
  });

  print('Authorization URL: $authorizationUrl');

  try {
    final result = await FlutterWebAuth.authenticate(
      url: authorizationUrl.toString(),
      callbackUrlScheme: callbackUrlScheme,
      preferEphemeral: false,
    );

    print('Authentication Successful! Result: $result');

    final String? code = Uri.parse(result).queryParameters['code'];
    if (code != null) {
      return await _fetchToken(code, codeVerifier);
    } else {
      print("No authorization code received!");
    }
  } catch (e) {
    print("Authentication Error: $e");
  }
  return null;
}

//************ Fetch Token Function (Returns User Data) *************//
Future<Map<String, dynamic>?> _fetchToken(
    String code, String codeVerifier) async {
  final Uri tokenUrl = Uri.parse('https://discord.com/api/oauth2/token');

  print('Fetching token with code: $code');

  final http.Response response = await http.post(
    tokenUrl,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'client_id': discordClientId,
      'client_secret': discordClientSecret,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': codeVerifier,
    },
  );

  print("Token Response Code: ${response.statusCode}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> tokenData = jsonDecode(response.body);
    final String accessToken = tokenData['access_token'];
    print('Access Token: $accessToken');
    return await _fetchUserData(accessToken);
  } else {
    print("Token Fetch Error: ${response.body}");
  }
  return null;
}

//************ Fetch User Data Function (Returns User Data) *************//
Future<Map<String, dynamic>?> _fetchUserData(String accessToken) async {
  final Uri userUrl = Uri.https('discord.com', '/api/users/@me');

  final http.Response response = await http.get(
    userUrl,
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  print('User Data Response Code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> userData = jsonDecode(response.body);
    return userData;
  } else {
    print('Fetch User Data Error: ${response.body}');
  }
  return null;
}

//************ Handle Authentication and Print User Data *************//
Future<void> _handleAuthentication() async {
  try {
    final userData = await authenticate();
    if (userData != null) {
      print('User Data: $userData');
    } else {
      print('Authentication failed.');
    }
  } catch (e) {
    print('Authentication error: $e');
  }
}
