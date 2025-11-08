/// Base interface for all use cases in the system
/// Provides consistent structure and lifecycle hooks for better maintainability
abstract class UseCase<Input, Output> {
  /// Execute the use case with the given input
  Future<Output> execute(Input input);

  /// Validate input before execution (optional override)
  Future<bool> validate(Input input) async => true;

  /// Hook called when execution fails (optional override)
  Future<void> onError(Exception error, Input input) async {}

  /// Hook called when execution succeeds (optional override)
  Future<void> onSuccess(Output result, Input input) async {}

  /// Execute with full lifecycle (validation, execution, hooks)
  Future<Output> call(Input input) async {
    try {
      final isValid = await validate(input);
      if (!isValid) {
        throw UseCaseValidationException('Input validation failed');
      }

      // Execute use case
      final result = await execute(input);

      // Success hook
      await onSuccess(result, input);

      return result;
    } on UseCaseException {
      rethrow;
    } catch (e) {
      final exception = e is Exception ? e : Exception(e.toString());
      await onError(exception, input);
      rethrow;
    }
  }
}

/// Base class for use cases that don't require input
abstract class NoInputUseCase<Output> {
  Future<Output> execute();

  Future<Output> call() async {
    return await execute();
  }
}

/// Base class for use cases that don't return output
abstract class NoOutputUseCase<Input> {
  Future<void> execute(Input input);

  Future<void> call(Input input) async {
    await execute(input);
  }
}

/// Base exception for all use case errors
class UseCaseException implements Exception {
  final String message;
  final String? code;
  final Object? details;

  UseCaseException(this.message, {this.code, this.details});

  @override
  String toString() {
    if (code != null) {
      return 'UseCaseException [$code]: $message';
    }
    return 'UseCaseException: $message';
  }
}

/// Validation exception
class UseCaseValidationException extends UseCaseException {
  UseCaseValidationException(String message, {String? code, Object? details})
      : super(message, code: code, details: details);
}

/// Not found exception
class EntityNotFoundException extends UseCaseException {
  final String entityType;
  final String entityId;

  EntityNotFoundException(this.entityType, this.entityId)
      : super('$entityType with ID $entityId not found',
            code: 'ENTITY_NOT_FOUND',
            details: {'entityType': entityType, 'entityId': entityId});
}

/// Conflict exception
class EntityConflictException extends UseCaseException {
  EntityConflictException(String message, {String? code, Object? details})
      : super(message, code: code ?? 'ENTITY_CONFLICT', details: details);
}

/// Unauthorized exception
class UnauthorizedException extends UseCaseException {
  UnauthorizedException(String message) : super(message, code: 'UNAUTHORIZED');
}

/// Business rule violation exception
class BusinessRuleViolationException extends UseCaseException {
  final String rule;

  BusinessRuleViolationException(this.rule, String message)
      : super(message,
            code: 'BUSINESS_RULE_VIOLATION', details: {'rule': rule});
}
