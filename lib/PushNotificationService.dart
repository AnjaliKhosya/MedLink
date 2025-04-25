import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "roomatesync-83596",
      "private_key_id": "436676e3f53ee7f1acc3f8d9fb3486dc2bfc239a",
      "private_key": """
-----BEGIN PRIVATE KEY-----
<YOUR PRIVATE KEY CONTENT HERE>
-----END PRIVATE KEY-----
""",
      "client_email": "roomatesync-serviceaccount@roomatesync-83596.iam.gserviceaccount.com",
      "client_id": "102724147447044438892",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/roomatesync-serviceaccount%40roomatesync-83596.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final httpClient = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      httpClient,
    );

    httpClient.close();
    return credentials.accessToken.data;
  }

  static Future<List<String>> fetchAllFcmTokens() async {
    List<String> tokens = [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('fcmToken') && data['fcmToken'] != null) {
        tokens.add(data['fcmToken']);
      }
    }

    return tokens;
  }
}
