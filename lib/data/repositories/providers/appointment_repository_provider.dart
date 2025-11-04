import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_management/data/datasources/local/appointment_data_source.dart';
import 'package:hospital_management/data/repositories/appointment_repository.dart';

final appointmentDataSourceProvider = Provider<AppointmentDataSource>((ref) {
  return LocalAppointmentDataSource();
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final dataSource = ref.watch(appointmentDataSourceProvider);
  return AppointmentRepositoryImpl(dataSource);
});
