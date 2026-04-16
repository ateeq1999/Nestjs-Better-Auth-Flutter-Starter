import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/organization.model.dart';
import '../../data/repositories/organization.repository.dart';
import '../../core/errors/app_exception.dart';

part 'org_list_state.dart';

class OrgListCubit extends Cubit<OrgListState> {
  OrgListCubit({required OrganizationRepository orgRepository})
      : _orgRepository = orgRepository,
        super(const OrgListInitial());

  final OrganizationRepository _orgRepository;

  Future<void> loadOrgs() async {
    if (state is OrgListLoading) return;
    emit(const OrgListLoading());
    try {
      final orgs = await _orgRepository.listOrgs();
      emit(OrgListLoaded(orgs));
    } on ApiException catch (e) {
      emit(OrgListFailure(e.message));
    } catch (e) {
      emit(OrgListFailure(e.toString()));
    }
  }

  Future<void> createOrg(String name) async {
    try {
      final org = await _orgRepository.createOrg(name);
      final current = state;
      if (current is OrgListLoaded) {
        emit(current.withOrg(org));
      }
    } on ApiException catch (e) {
      emit(OrgListFailure(e.message));
    } catch (e) {
      emit(OrgListFailure(e.toString()));
    }
  }

  Future<void> deleteOrg(String id) async {
    try {
      await _orgRepository.deleteOrg(id);
      final current = state;
      if (current is OrgListLoaded) {
        emit(current.withoutOrg(id));
      }
    } on ApiException catch (e) {
      emit(OrgListFailure(e.message));
    } catch (e) {
      emit(OrgListFailure(e.toString()));
    }
  }
}
