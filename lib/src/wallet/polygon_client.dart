import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../core/constants.dart';
import '../core/trading_exceptions.dart';

/// Client for Polygon blockchain operations.
///
/// Provides methods for checking balances, transferring USDC,
/// and managing token approvals.
class PolygonClient {
  final Web3Client _web3;
  final int chainId;

  PolygonClient({
    String? rpcUrl,
    this.chainId = PolymarketConstants.polygonChainId,
    http.Client? httpClient,
  }) : _web3 = Web3Client(
          rpcUrl ?? PolymarketConstants.polygonRpcUrl,
          httpClient ?? http.Client(),
        );

  /// Get native MATIC balance.
  Future<double> getMaticBalance(String address) async {
    final balance = await _web3.getBalance(EthereumAddress.fromHex(address));
    return balance.getInWei.toDouble() / 1e18;
  }

  /// Get USDC balance.
  Future<double> getUsdcBalance(String address) async {
    final contract = _usdcContract;
    final balanceOf = contract.function('balanceOf');

    final result = await _web3.call(
      contract: contract,
      function: balanceOf,
      params: [EthereumAddress.fromHex(address)],
    );

    final balance = result.first as BigInt;
    return balance.toDouble() / 1e6; // USDC has 6 decimals
  }

  /// Transfer USDC to another address.
  ///
  /// Returns the transaction hash.
  Future<String> transferUsdc({
    required EthPrivateKey credentials,
    required String toAddress,
    required double amount,
  }) async {
    final contract = _usdcContract;
    final transfer = contract.function('transfer');
    final amountWei = BigInt.from((amount * 1e6).round());

    final txHash = await _web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transfer,
        parameters: [
          EthereumAddress.fromHex(toAddress),
          amountWei,
        ],
      ),
      chainId: chainId,
    );

    return txHash;
  }

  /// Approve USDC spending for a contract.
  ///
  /// If [amount] is null, approves max uint256 (unlimited).
  /// Returns the transaction hash.
  Future<String> approveUsdc({
    required EthPrivateKey credentials,
    required String spenderAddress,
    BigInt? amount,
  }) async {
    final contract = _usdcContract;
    final approve = contract.function('approve');

    // Max approval if not specified
    final approveAmount = amount ??
        BigInt.parse(
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
          radix: 16,
        );

    final txHash = await _web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: approve,
        parameters: [
          EthereumAddress.fromHex(spenderAddress),
          approveAmount,
        ],
      ),
      chainId: chainId,
    );

    return txHash;
  }

  /// Approve USDC for the CTF Exchange contract.
  Future<String> approveUsdcForExchange({
    required EthPrivateKey credentials,
    bool negRisk = false,
  }) {
    return approveUsdc(
      credentials: credentials,
      spenderAddress: negRisk
          ? PolymarketConstants.negRiskExchangeAddress
          : PolymarketConstants.exchangeAddress,
    );
  }

  /// Check USDC allowance for a spender.
  Future<double> getUsdcAllowance({
    required String ownerAddress,
    required String spenderAddress,
  }) async {
    final contract = _usdcContract;
    final allowance = contract.function('allowance');

    final result = await _web3.call(
      contract: contract,
      function: allowance,
      params: [
        EthereumAddress.fromHex(ownerAddress),
        EthereumAddress.fromHex(spenderAddress),
      ],
    );

    final amount = result.first as BigInt;
    return amount.toDouble() / 1e6;
  }

  /// Check if USDC is approved for the exchange.
  Future<bool> isUsdcApprovedForExchange({
    required String ownerAddress,
    bool negRisk = false,
    double minAmount = 1000000, // 1M USDC default threshold
  }) async {
    final allowance = await getUsdcAllowance(
      ownerAddress: ownerAddress,
      spenderAddress: negRisk
          ? PolymarketConstants.negRiskExchangeAddress
          : PolymarketConstants.exchangeAddress,
    );
    return allowance >= minAmount;
  }

  /// Wait for transaction confirmation.
  ///
  /// Returns the receipt or null if timed out.
  Future<TransactionReceipt?> waitForTransaction(
    String txHash, {
    Duration timeout = const Duration(minutes: 2),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      final receipt = await _web3.getTransactionReceipt(txHash);
      if (receipt != null) {
        return receipt;
      }
      await Future.delayed(pollInterval);
    }

    return null;
  }

  /// Wait for transaction and throw if it fails or times out.
  Future<TransactionReceipt> waitForTransactionOrThrow(
    String txHash, {
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final receipt = await waitForTransaction(txHash, timeout: timeout);

    if (receipt == null) {
      throw TransactionTimeoutException(timeout: timeout, txHash: txHash);
    }

    if (receipt.status == false) {
      throw TransactionFailedException(
        'Transaction reverted',
        txHash: txHash,
      );
    }

    return receipt;
  }

  /// Get current gas price in Gwei.
  Future<double> getGasPriceGwei() async {
    final gasPrice = await _web3.getGasPrice();
    return gasPrice.getInWei.toDouble() / 1e9;
  }

  /// Get current block number.
  Future<int> getBlockNumber() async {
    return await _web3.getBlockNumber();
  }

  DeployedContract get _usdcContract => DeployedContract(
        ContractAbi.fromJson(_usdcAbi, 'USDC'),
        EthereumAddress.fromHex(PolymarketConstants.usdcAddress),
      );

  /// Dispose the client and release resources.
  void dispose() {
    _web3.dispose();
  }

  static const String _usdcAbi = '''[
    {"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"}
  ]''';
}
