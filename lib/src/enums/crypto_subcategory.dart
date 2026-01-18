/// Subcategories for cryptocurrency markets.
enum CryptoSubcategory {
  /// Bitcoin
  bitcoin('bitcoin', 'Bitcoin'),

  /// Ethereum
  ethereum('ethereum', 'Ethereum'),

  /// Solana
  solana('solana', 'Solana'),

  /// XRP/Ripple
  xrp('xrp', 'XRP'),

  /// Dogecoin
  doge('doge', 'Dogecoin'),

  /// Cardano
  cardano('cardano', 'Cardano'),

  /// Polygon
  polygon('polygon', 'Polygon'),

  /// Avalanche
  avalanche('avalanche', 'Avalanche'),

  /// Polkadot
  polkadot('polkadot', 'Polkadot'),

  /// Chainlink
  chainlink('chainlink', 'Chainlink'),

  /// Uniswap
  uniswap('uniswap', 'Uniswap'),

  /// Aave
  aave('aave', 'Aave'),

  /// DeFi
  defi('defi', 'DeFi'),

  /// NFTs
  nft('nft', 'NFTs'),

  /// Stablecoins
  stablecoins('stablecoins', 'Stablecoins'),

  /// Layer 2
  layer2('layer-2', 'Layer 2'),

  /// Memecoins
  memecoins('memecoins', 'Memecoins'),

  /// Bitcoin ETF
  bitcoinEtf('bitcoin-etf', 'Bitcoin ETF'),

  /// Ethereum ETF
  ethereumEtf('ethereum-etf', 'Ethereum ETF'),

  /// Crypto regulation
  regulation('crypto-regulation', 'Crypto Regulation'),

  /// Crypto exchanges
  exchanges('crypto-exchanges', 'Exchanges'),

  /// Binance
  binance('binance', 'Binance'),

  /// Coinbase
  coinbase('coinbase', 'Coinbase'),

  /// FTX
  ftx('ftx', 'FTX'),

  /// Mining
  mining('mining', 'Mining'),

  /// Staking
  staking('staking', 'Staking'),

  /// Price predictions
  pricePredictions('crypto-price', 'Price Predictions'),

  /// Altcoins
  altcoins('altcoins', 'Altcoins'),

  /// Web3
  web3('web3', 'Web3'),

  /// DAOs
  dao('dao', 'DAOs'),

  /// Other crypto
  other('other-crypto', 'Other Crypto');

  final String slug;
  final String label;

  const CryptoSubcategory(this.slug, this.label);

  String toJson() => slug;

  static CryptoSubcategory fromJson(String json) {
    return CryptoSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => CryptoSubcategory.other,
    );
  }

  static CryptoSubcategory? bySlug(String slug) {
    try {
      return CryptoSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}
