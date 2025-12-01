import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> get isConnected async {
    // 1. Verificação rápida de rede (Wi-Fi/Dados)
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool hasNetwork = connectivityResult.contains(ConnectivityResult.mobile) || 
                      connectivityResult.contains(ConnectivityResult.wifi) || 
                      connectivityResult.contains(ConnectivityResult.ethernet);

    if (!hasNetwork) {
      return false;
    }

    // 2. Verificação REAL de internet (DNS Lookup)
    // Isso resolve o problema de "Wi-Fi conectado mas sem internet" e "falso positivo".
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    
    return false;
  }
}
