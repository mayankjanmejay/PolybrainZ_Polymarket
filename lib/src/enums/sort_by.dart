/// Fields available for sorting.
enum SortBy {
  current('CURRENT'),
  initial('INITIAL'),
  tokens('TOKENS'),
  cashPnl('CASHPNL'),
  percentPnl('PERCENTPNL'),
  title('TITLE'),
  resolving('RESOLVING'),
  price('PRICE'),
  avgPrice('AVGPRICE'),
  timestamp('TIMESTAMP'),
  size('SIZE'),
  volume('VOLUME'),
  liquidity('LIQUIDITY'),
  startDate('START_DATE'),
  endDate('END_DATE'),
  createdAt('CREATED_AT');

  const SortBy(this.value);
  final String value;

  String toJson() => value;

  static SortBy fromJson(String json) {
    return SortBy.values.firstWhere(
      (e) => e.value.toUpperCase() == json.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid SortBy: $json'),
    );
  }
}
