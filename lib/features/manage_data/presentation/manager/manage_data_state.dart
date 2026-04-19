// lib/features/manage_data/presentation/manager/manage_data_state.dart

part of 'manage_data_cubit.dart';

sealed class ManageDataState {}

final class ManageDataInitial extends ManageDataState {}

final class ManageDataLoading extends ManageDataState {}

/// البيانات المحلية تم جلبها بنجاح
final class ManageDataLoaded extends ManageDataState {
  final List<LocalDataEntity> items;
  ManageDataLoaded(this.items);
}

/// لا توجد بيانات محلية
final class ManageDataEmpty extends ManageDataState {}

/// خطأ أثناء جلب أو حذف البيانات
final class ManageDataError extends ManageDataState {
  final String message;
  ManageDataError(this.message);
}
