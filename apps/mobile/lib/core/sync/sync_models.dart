enum SyncOperationState { pending, uploading, synced, failed, conflict }

final class SyncStatus {
  const SyncStatus({
    this.pendingCount = 0,
    this.conflictCount = 0,
    this.isSynchronizing = false,
    this.lastSuccessfulSyncAt,
    this.lastError,
  });

  final int pendingCount;
  final int conflictCount;
  final bool isSynchronizing;
  final DateTime? lastSuccessfulSyncAt;
  final String? lastError;

  SyncStatus copyWith({
    int? pendingCount,
    int? conflictCount,
    bool? isSynchronizing,
    DateTime? lastSuccessfulSyncAt,
    String? lastError,
    bool clearError = false,
  }) => SyncStatus(
    pendingCount: pendingCount ?? this.pendingCount,
    conflictCount: conflictCount ?? this.conflictCount,
    isSynchronizing: isSynchronizing ?? this.isSynchronizing,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
    lastError: clearError ? null : (lastError ?? this.lastError),
  );
}
