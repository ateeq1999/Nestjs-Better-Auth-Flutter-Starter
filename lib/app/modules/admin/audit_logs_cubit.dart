import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/audit_log.model.dart';
import '../../data/repositories/admin.repository.dart';
import '../../core/errors/app_exception.dart';

part 'audit_logs_state.dart';

class AuditLogsCubit extends Cubit<AuditLogsState> {
  AuditLogsCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AuditLogsInitial());

  final AdminRepository _adminRepository;

  Future<void> loadLogs({String? userId}) async {
    if (state is AuditLogsLoading) return;
    emit(const AuditLogsLoading());
    try {
      final result = await _adminRepository.listAuditLogs(userId: userId);
      emit(AuditLogsLoaded(
        logs: result.logs,
        cursor: result.cursor,
        hasMore: result.hasMore,
        userId: userId,
      ));
    } on ApiException catch (e) {
      emit(AuditLogsFailure(e.message));
    } catch (e) {
      emit(AuditLogsFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! AuditLogsLoaded || !current.hasMore) return;
    try {
      final result = await _adminRepository.listAuditLogs(
        userId: current.userId,
        cursor: current.cursor,
      );
      emit(current.copyWith(
        logs: [...current.logs, ...result.logs],
        cursor: result.cursor,
        hasMore: result.hasMore,
      ));
    } on ApiException catch (e) {
      emit(AuditLogsFailure(e.message));
    } catch (e) {
      emit(AuditLogsFailure(e.toString()));
    }
  }
}
