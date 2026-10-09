import 'package:equatable/equatable.dart';
import '../data/local_vault_item.dart';

class LocalVaultState extends Equatable {
  const LocalVaultState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<LocalVaultItem> items;
  final bool isLoading;
  final String? error; // one-shot: cleared by the next state

  int get totalBytes => items.fold(0, (sum, e) => sum + e.sizeBytes);

  /// [error] is NOT copied, so it lasts for one state only.
  LocalVaultState copyWith({
    List<LocalVaultItem>? items,
    bool? isLoading,
    String? error,
  }) => LocalVaultState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  List<Object?> get props => [items, isLoading, error];
}
