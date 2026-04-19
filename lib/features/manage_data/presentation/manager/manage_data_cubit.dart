// lib/features/manage_data/presentation/manager/manage_data_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/delete_local_data_usecase.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/get_local_data_usecase.dart';

part 'manage_data_state.dart';

class ManageDataCubit extends Cubit<ManageDataState> {
  ManageDataCubit({
    required this.getLocalDataUseCase,
    required this.deleteLocalDataUseCase,
  }) : super(ManageDataInitial());

  final GetLocalDataUseCase getLocalDataUseCase;
  final DeleteLocalDataUseCase deleteLocalDataUseCase;

  // قائمة البيانات الحالية في الذاكرة لتحديث UI بدون re-fetch
  List<LocalDataEntity> _currentItems = [];

  Future<void> loadLocalData() async {
    emit(ManageDataLoading());

    final result = await getLocalDataUseCase();

    result.fold(
      (failure) => emit(ManageDataError(failure.message)),
      (items) {
        _currentItems = List.from(items);
        if (items.isEmpty) {
          emit(ManageDataEmpty());
        } else {
          emit(ManageDataLoaded(items));
        }
      },
    );
  }

  Future<void> deleteItem(String id) async {
    // حذف فوري من الـ UI بدون loading كامل
    _currentItems.removeWhere((item) => item.id == id);

    if (_currentItems.isEmpty) {
      emit(ManageDataEmpty());
    } else {
      emit(ManageDataLoaded(List.from(_currentItems)));
    }

    // ثم تنفيذ الحذف الفعلي في SharedPreferences
    final result = await deleteLocalDataUseCase(id);

    result.fold(
      (failure) {
        // إعادة البيانات إذا فشل الحذف
        emit(ManageDataError(failure.message));
        loadLocalData();
      },
      (_) {
        // تم الحذف بنجاح — الـ UI محدّث بالفعل
      },
    );
  }
}
