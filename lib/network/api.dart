import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// class api (untuk membantu menyederhanakan kode program)
class NetworkAPI {
  // alamat server api
  final _url = 'https://smartdoorlock.my.id/api';

  // fungsi untuk mendapatkan token user pada shared_preferences
  getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString('token');
  }

  getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var userData = storage.getString('userData');
    var user = json.decode(userData!);
    return user['id'];
  }

  // fungsi untuk melakukan request get
  getAPI(endpoint, isTokenable) async {
    var fullUrl = _url + endpoint;

    // jika enpoint api membutuhkan akses login maka sertakan token pada header request
    if (isTokenable) {
      return await http.get(
        Uri.parse(fullUrl),
        headers: _setTokenableHeader(await getToken()),
      );
    }

    // jika tidak butuh akses login maka tidak perlu token
    return await http.get(
      Uri.parse(fullUrl),
      headers: _setHeader(),
    );
  }

  // fungsi untuk request post
  postAPI(endpoint, isTokenable, data) async {
    var fullUrl = _url + endpoint;

    // jika perlu akses login
    if (isTokenable) {
      return await http.post(
        Uri.parse(fullUrl),
        headers: _setTokenableHeader(await getToken()),
        body: data,
      );
    }

    // jika tidak perlu akses login
    return await http.post(
      Uri.parse(fullUrl),
      headers: _setHeader(),
      body: data,
    );
  }

  getSignature(socketId, officeId) async {
    return await http.post(
      Uri.parse("https://smartdoorlock.my.id/api/get-signature"),
      headers: _setTokenableHeader(await getToken()),
      body: {
        "socket_id": socketId,
        "office_id": officeId,
        "channel_data":
            "{\"user_id\":\"${await NetworkAPI().getUserId()}\",\"user_info\":true}",
      },
    );
  }

  // fungsi login api
  authLogin(email, password) async {
    var fullUrl = '$_url/login';
    // request post ke enpoint login
    return await http.post(
      Uri.parse(fullUrl),
      headers: _setHeader(),
      body: {'email': email, 'password': password},
    );
  }

  // header tanpa token
  _setHeader() => {
        'Accept': 'application/json',
      };

  // header dengan token
  _setTokenableHeader(token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
