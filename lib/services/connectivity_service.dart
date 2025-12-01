import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> get isConnected async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || 
        connectivityResult.contains(ConnectivityResult.wifi) || 
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }
}
