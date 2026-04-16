import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/snackbar_helper.dart';
import 'audit_logs_cubit.dart';

class AuditLogsView extends StatefulWidget {
  const AuditLogsView({super.key});

  @override
  State<AuditLogsView> createState() => _AuditLogsViewState();
}

class _AuditLogsViewState extends State<AuditLogsView> {
  @override
  void initState() {
    super.initState();
    context.read<AuditLogsCubit>().loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: BlocConsumer<AuditLogsCubit, AuditLogsState>(
        listener: (context, state) {
          if (state is AuditLogsFailure) {
            SnackbarHelper.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuditLogsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuditLogsLoaded) {
            if (state.logs.isEmpty) {
              return const Center(child: Text('No audit logs found.'));
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  context.read<AuditLogsCubit>().loadMore();
                }
                return false;
              },
              child: ListView.separated(
                itemCount: state.logs.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i == state.logs.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final log = state.logs[i];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(log.action),
                    subtitle: Text(
                      'User: ${log.userId}\n${log.createdAt.toLocal()}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
