import 'dart:convert';
// import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcurl = "http://Blockchainhost:port";
  final String _wsurl = "ws://Blockchainhost:port";
  final String _privatekey =
      "Your private key";
  bool isLoading = true;

  late Web3Client _client;
  var name;

  late String _abiCode;
  late EthereumAddress _contractAddress;

  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _string;
  late ContractFunction _setString;

  late String deployedString;
  late ServerSocket _socket;

  ContractLinking() {
    initialSetup();
  }

  initialSetup() async {
    _client = Web3Client(_rpcurl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsurl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
    _socket = await ServerSocket.bind("host", 51489port);
    print('Listening on ${_socket.address}:${_socket.port}');

    await for (final clientSocket in _socket) {
      print(
          'Client connected: ${clientSocket.remoteAddress}:${clientSocket.remotePort}');

      clientSocket.listen(
        (data) {
          final message = utf8.decode(data);
          print('Received data from client: $message');
          setString(message);
        },
        onError: (error) {
          print('Error: $error');
          clientSocket.destroy();
        },
        onDone: () {
          print('Client disconnected');
          clientSocket.destroy();
        },
      );
    }
  }

  Future<void> getAbi() async {
    String abiStringFile = await rootBundle.loadString("assets/Test1.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    // ignore: deprecated_member_use
    _credentials = await _client.credentialsFromPrivateKey(_privatekey);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "Test1"), _contractAddress);
    _setString = _contract.function("setString");
    _string = _contract.function("getString");
    getString(0);
  }

  getString(int a) async {
    if (a == 0) {
      name = await _client.call(
          contract: _contract,
          function: _string,
          params: [],
          atBlock: BlockNum.current());
    } else {
      name = await _client.call(
          contract: _contract,
          function: _string,
          params: [],
          atBlock: BlockNum.exact(a));
    }
    deployedString = name[0];
    isLoading = false;
    notifyListeners();
  }

  setString(String stringToSet) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _setString,
            parameters: [stringToSet]));
    getString(0);
  }
}
