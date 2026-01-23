import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';

void main() {
  group('HdWallet', () {
    group('generateMnemonic', () {
      test('generates 24-word mnemonic by default', () {
        final mnemonic = HdWallet.generateMnemonic();
        final words = mnemonic.split(' ');
        expect(words.length, equals(24));
      });

      test('generates 12-word mnemonic with generateMnemonic12', () {
        final mnemonic = HdWallet.generateMnemonic12();
        final words = mnemonic.split(' ');
        expect(words.length, equals(12));
      });

      test('generated mnemonic is valid', () {
        final mnemonic = HdWallet.generateMnemonic();
        expect(HdWallet.validateMnemonic(mnemonic), isTrue);
      });

      test('generates unique mnemonics each time', () {
        final mnemonic1 = HdWallet.generateMnemonic();
        final mnemonic2 = HdWallet.generateMnemonic();
        expect(mnemonic1, isNot(equals(mnemonic2)));
      });
    });

    group('validateMnemonic', () {
      test('accepts valid 12-word mnemonic', () {
        const mnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        expect(HdWallet.validateMnemonic(mnemonic), isTrue);
      });

      test('accepts valid 24-word mnemonic', () {
        const mnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art';
        expect(HdWallet.validateMnemonic(mnemonic), isTrue);
      });

      test('rejects invalid mnemonic', () {
        const mnemonic = 'not a valid mnemonic phrase at all';
        expect(HdWallet.validateMnemonic(mnemonic), isFalse);
      });

      test('rejects empty string', () {
        expect(HdWallet.validateMnemonic(''), isFalse);
      });

      test('rejects wrong word count', () {
        const mnemonic = 'abandon abandon abandon abandon abandon';
        expect(HdWallet.validateMnemonic(mnemonic), isFalse);
      });
    });

    group('deriveWallet', () {
      // Standard test mnemonic - DO NOT USE IN PRODUCTION
      const testMnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

      test('derives wallet from valid mnemonic', () {
        final wallet = HdWallet.deriveWallet(
          mnemonic: testMnemonic,
          index: 0,
        );

        expect(wallet.address, isNotEmpty);
        expect(wallet.address.startsWith('0x'), isTrue);
        expect(wallet.address.length, equals(42));
        expect(wallet.privateKey.startsWith('0x'), isTrue);
        expect(wallet.privateKey.length, equals(66));
        expect(wallet.derivationIndex, equals(0));
      });

      test('derives deterministic addresses', () {
        final wallet1 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 0);
        final wallet2 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 0);

        expect(wallet1.address, equals(wallet2.address));
        expect(wallet1.privateKey, equals(wallet2.privateKey));
      });

      test('derives different addresses for different indices', () {
        final wallet0 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 0);
        final wallet1 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 1);
        final wallet2 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 2);

        expect(wallet0.address, isNot(equals(wallet1.address)));
        expect(wallet1.address, isNot(equals(wallet2.address)));
        expect(wallet0.address, isNot(equals(wallet2.address)));
      });

      test('throws on invalid mnemonic', () {
        expect(
          () => HdWallet.deriveWallet(mnemonic: 'invalid mnemonic', index: 0),
          throwsArgumentError,
        );
      });

      test('throws on negative index', () {
        expect(
          () => HdWallet.deriveWallet(mnemonic: testMnemonic, index: -1),
          throwsArgumentError,
        );
      });

      test('stores correct derivation index', () {
        final wallet5 = HdWallet.deriveWallet(mnemonic: testMnemonic, index: 5);
        expect(wallet5.derivationIndex, equals(5));
      });
    });

    group('deriveWallets', () {
      const testMnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

      test('derives multiple wallets', () {
        final wallets = HdWallet.deriveWallets(
          mnemonic: testMnemonic,
          count: 5,
        );

        expect(wallets.length, equals(5));
        for (var i = 0; i < 5; i++) {
          expect(wallets[i].derivationIndex, equals(i));
        }
      });

      test('respects startIndex parameter', () {
        final wallets = HdWallet.deriveWallets(
          mnemonic: testMnemonic,
          count: 3,
          startIndex: 10,
        );

        expect(wallets.length, equals(3));
        expect(wallets[0].derivationIndex, equals(10));
        expect(wallets[1].derivationIndex, equals(11));
        expect(wallets[2].derivationIndex, equals(12));
      });

      test('throws on non-positive count', () {
        expect(
          () => HdWallet.deriveWallets(mnemonic: testMnemonic, count: 0),
          throwsArgumentError,
        );
        expect(
          () => HdWallet.deriveWallets(mnemonic: testMnemonic, count: -1),
          throwsArgumentError,
        );
      });

      test('derived wallets match individual derivation', () {
        final wallets = HdWallet.deriveWallets(
          mnemonic: testMnemonic,
          count: 3,
        );

        for (var i = 0; i < 3; i++) {
          final individual =
              HdWallet.deriveWallet(mnemonic: testMnemonic, index: i);
          expect(wallets[i].address, equals(individual.address));
          expect(wallets[i].privateKey, equals(individual.privateKey));
        }
      });
    });

    group('getAddress', () {
      test('gets address from private key with 0x prefix', () {
        // Known test private key
        const privateKey =
            '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
        final address = HdWallet.getAddress(privateKey);

        expect(address, isNotEmpty);
        expect(address.startsWith('0x'), isTrue);
        expect(address.length, equals(42));
      });

      test('gets address from private key without 0x prefix', () {
        const privateKey =
            'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
        final address = HdWallet.getAddress(privateKey);

        expect(address, isNotEmpty);
        expect(address.startsWith('0x'), isTrue);
      });

      test('returns checksum address (EIP-55)', () {
        const privateKey =
            '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
        final address = HdWallet.getAddress(privateKey);

        // EIP-55 checksum addresses have mixed case
        expect(address.contains(RegExp(r'[A-F]')), isTrue);
      });
    });
  });

  group('WalletCredentials', () {
    test('stores address, privateKey, and derivationIndex', () {
      const creds = WalletCredentials(
        address: '0x1234567890123456789012345678901234567890',
        privateKey: '0xabcdef',
        derivationIndex: 5,
      );

      expect(creds.address, equals('0x1234567890123456789012345678901234567890'));
      expect(creds.privateKey, equals('0xabcdef'));
      expect(creds.derivationIndex, equals(5));
    });

    test('equality works correctly', () {
      const creds1 = WalletCredentials(
        address: '0x1234',
        privateKey: '0xabcd',
        derivationIndex: 0,
      );
      const creds2 = WalletCredentials(
        address: '0x1234',
        privateKey: '0xabcd',
        derivationIndex: 0,
      );
      const creds3 = WalletCredentials(
        address: '0x5678',
        privateKey: '0xefgh',
        derivationIndex: 1,
      );

      expect(creds1, equals(creds2));
      expect(creds1, isNot(equals(creds3)));
    });
  });
}
