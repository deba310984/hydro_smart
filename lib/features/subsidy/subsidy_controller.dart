import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subsidy_repository.dart';
import 'subsidy_model.dart';

final subsidyRepositoryProvider = Provider((ref) {
  return SubsidyRepository();
});

final subsidyStreamProvider = StreamProvider<List<SubsidyModel>>((ref) {
  final repo = ref.watch(subsidyRepositoryProvider);
  return repo.streamSubsidies();
});
