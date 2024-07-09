import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nonce/nonce.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import '../../model/account.dart';
import '../../model/wallet_provider.dart';

/// Manages the authentication process and communication with crypto wallets
abstract class AuthenticationService {
  List<WalletProvider> get availableWallets;

  Account? get authenticatedAccount;

  String get operatingChainName;

  bool get isOnOperatingChain;

  bool get isAuthenticated;

  String? get webQrData;

  requestAuthentication({WalletProvider? walletProvider});

  unauthenticate();
}

class AuthenticationServiceImpl implements AuthenticationService {
  @override
  late final List<WalletProvider> availableWallets;

  final int operatingChain;
  Web3App? _connector;
  Function() onAuthStatusChanged;

  @override
  String get operatingChainName => operatingChain == 1001 ? 'Klaytn Testnet' : 'Chain $operatingChain';

  @override
  Account? get authenticatedAccount => _authenticatedAccount;
  Account? _authenticatedAccount;

  @override
  bool get isOnOperatingChain => currentChain == operatingChain;

  SessionData? get currentSession => _connector?.sessions.getAll().firstOrNull;

  int? get currentChain => int.tryParse(currentSession?.namespaces['eip155']?.accounts.first.split(':')[1] ?? '');

  @override
  bool get isAuthenticated => isConnected && authenticatedAccount != null;

  bool get isConnected => currentSession != null;

  // The data to display in a QR Code for connections on Desktop / Browser.
  @override
  String? webQrData;

  AuthenticationServiceImpl({
    required this.operatingChain,
    required this.onAuthStatusChanged,
  }) {
    if (kIsWeb) {
      requestAuthentication();
    } else {
      _loadWallets();
    }
  }

  /// Loads all WalletConnect compatible wallets
  _loadWallets() async {
    final walletResponse = await http.get(Uri.parse('https://registry.walletconnect.org/data/wallets.json'));
    final walletData = json.decode(walletResponse.body);
    availableWallets = walletData.entries.map<WalletProvider>((data) => WalletProvider.fromJson(data.value)).toList();
  }

  /// Prompts user to authenticate with a wallet
  @override
  requestAuthentication({WalletProvider? walletProvider}) async {
    // Create fresh connector
    await _createConnector(walletProvider: walletProvider);

    // Create a new session
    if (!isConnected) {
      try {
        ConnectResponse resp = await _connector!.connect(
          requiredNamespaces: {
            'eip155': RequiredNamespace(
              chains: ['eip155:$operatingChain'],
              methods: ['personal_sign'],
              events: [],
            ),
          },
        );

        Uri? uri = resp.uri;
        if (uri != null) {
          if (kIsWeb) {
            webQrData = uri.toString();
            onAuthStatusChanged();
          } else {
            _launchWallet(wallet: walletProvider, uri: uri.toString());
          }
        }

        onAuthStatusChanged();
      } catch (e) {
        log('Error during connect: $e', name: 'AuthenticationService');
      }
    }
  }

  /// Send request to the users wallet to sign a message
  /// User will be authenticated if the signature could be verified
  Future<bool> _verifySignature({WalletProvider? walletProvider, String? address}) async {
    if (address == null || currentChain == null || !isOnOperatingChain) return false;

    if (!kIsWeb) {
      // Launch wallet app if on mobile
      // Delay to make sure FlutterBird is in foreground before launching wallet app again
      await Future.delayed(const Duration(seconds: 1));
      // v2 doesn't have a uri property in currentSession so you need to get the proper URI.
      _launchWallet(wallet: walletProvider, uri: 'wc:${currentSession!.topic}@2?relay-protocol=irn&symKey=${currentSession!.relay.protocol}');
    }

    log('Signing message...', name: 'AuthenticationService');

    // Let Crypto Wallet sign custom message
    String nonce = Nonce.generate(32, math.Random.secure());
    String messageText = 'Please sign this message to authenticate with Flutter Bird.\nChallenge: $nonce';
    final String signature = await _connector!.request(
      topic: currentSession!.topic,
      chainId: 'eip155:$currentChain',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [messageText, address],
      ),
    );

    // Check if signature is valid by recovering the exact address from message and signature
    String recoveredAddress = EthSigUtil.recoverPersonalSignature(
        signature: signature, message: Uint8List.fromList(utf8.encode(messageText)));

    // if initial address and recovered address are identical the message has been signed with the correct private key
    bool isAuthenticated = recoveredAddress.toLowerCase() == address.toLowerCase();

    // Set authenticated account
    _authenticatedAccount = isAuthenticated ? Account(address: recoveredAddress, chainId: currentChain!) : null;

    return isAuthenticated;
  }

  @override
  unauthenticate() async {
    if (currentSession != null) {
      await _connector?.disconnectSession(topic: currentSession!.topic, reason: Errors.getSdkError(Errors.USER_DISCONNECTED));
    }
    _authenticatedAccount = null;
    _connector = null;
    webQrData = null;
  }

  /// Creates a WalletConnect Instance
  Future<void> _createConnector({WalletProvider? walletProvider}) async {
    // Create WalletConnect Connector
    try {
      _connector = await Web3App.createInstance(
        projectId: dotenv.env['WALLET_CONNECT_PROJECT_ID']!,
        metadata: const PairingMetadata(
          name: 'Flutter Bird',
          description: 'WalletConnect Developer App',
          url: 'https://flutterbird.com',
          icons: [
            'https://raw.githubusercontent.com/Tonnanto/flutter-bird/v1.0/flutter_bird_app/assets/icon.png',
          ],
        ),
      );

      // Subscribe to events
      _connector?.onSessionConnect.subscribe((SessionConnect? session) async {
        log('connected: ' + session.toString(), name: 'AuthenticationService');
        String? address = session?.session.namespaces['eip155']?.accounts.first.split(':').last;
        webQrData = null;
        final authenticated = await _verifySignature(walletProvider: walletProvider, address: address);
        if (authenticated) log('authenticated successfully: ' + session.toString(), name: 'AuthenticationService');
        onAuthStatusChanged();
      });
      _connector?.onSessionUpdate.subscribe((SessionUpdate? payload) async {
        log('session_update: ' + payload.toString(), name: 'AuthenticationService');
        webQrData = null;
        onAuthStatusChanged();
      });
      _connector?.onSessionDelete.subscribe((SessionDelete? session) {
        log('disconnect: ' + session.toString(), name: 'AuthenticationService');
        webQrData = null;
        _authenticatedAccount = null;
        onAuthStatusChanged();
      });
    } catch (e) {
      log('Error during connector creation: $e', name: 'AuthenticationService');
    }
  }

  Future<void> _launchWallet({
    WalletProvider? wallet,
    required String uri,
  }) async {
    if (wallet == null) {
      launchUrl(Uri.parse(uri));
      return;
    }

    if (wallet.universal != null && await canLaunchUrl(Uri.parse(wallet.universal!))) {
      await launchUrl(
        _convertToWcUri(appLink: wallet.universal!, wcUri: uri),
        mode: LaunchMode.externalApplication,
      );
    } else if (wallet.native != null && await canLaunchUrl(Uri.parse(wallet.native!))) {
      await launchUrl(
        _convertToWcUri(appLink: wallet.native!, wcUri: uri),
      );
    } else {
      if (Platform.isIOS && wallet.iosLink != null) {
        await launchUrl(Uri.parse(wallet.iosLink!));
      } else if (Platform.isAndroid && wallet.androidLink != null) {
        await launchUrl(Uri.parse(wallet.androidLink!));
      }
    }
  }

  Uri _convertToWcUri({
    required String appLink,
    required String wcUri,
  }) =>
      Uri.parse('$appLink/wc?uri=${Uri.encodeComponent(wcUri)}');
}
