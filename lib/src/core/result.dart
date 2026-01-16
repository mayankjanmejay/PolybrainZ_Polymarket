/// A Result type for operations that can fail.
///
/// Use this instead of exceptions for expected failure cases.
sealed class Result<T, E> {
  const Result();

  /// Whether this is a success
  bool get isSuccess => this is Success<T, E>;

  /// Whether this is a failure
  bool get isFailure => this is Failure<T, E>;

  /// Get the value if success, or null if failure
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Get the error if failure, or null if success
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Map the success value
  Result<U, E> map<U>(U Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Failure(:final error) => Failure(error),
      };

  /// Map the failure error
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
        Success(:final value) => Success(value),
        Failure(:final error) => Failure(transform(error)),
      };

  /// FlatMap the success value
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) =>
      switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Failure(error),
      };

  /// Execute one of two functions based on success/failure
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(E error) onFailure,
  ) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final error) => onFailure(error),
      };

  /// Get value or throw
  T getOrThrow() => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => throw error as Object,
      };

  /// Get value or default
  T getOrElse(T defaultValue) => switch (this) {
        Success(:final value) => value,
        Failure() => defaultValue,
      };

  /// Get value or compute default
  T getOrElseCompute(T Function(E error) compute) => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => compute(error),
      };
}

/// Successful result containing a value.
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T, E> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failed result containing an error.
final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T, E> && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension for async Result handling
extension ResultFuture<T, E> on Future<Result<T, E>> {
  /// Map success value asynchronously
  Future<Result<U, E>> mapAsync<U>(
      Future<U> Function(T value) transform) async {
    final result = await this;
    return switch (result) {
      Success(:final value) => Success(await transform(value)),
      Failure(:final error) => Failure(error),
    };
  }
}

/// Helper to create Results
class Results {
  Results._();

  /// Create a success result
  static Result<T, E> success<T, E>(T value) => Success(value);

  /// Create a failure result
  static Result<T, E> failure<T, E>(E error) => Failure(error);

  /// Try an operation and wrap in Result
  static Result<T, Exception> trySync<T>(T Function() operation) {
    try {
      return Success(operation());
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  /// Try an async operation and wrap in Result
  static Future<Result<T, Exception>> tryAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Success(await operation());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
