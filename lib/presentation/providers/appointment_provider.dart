import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_management/domain/entities/appointment.dart';
import 'package:hospital_management/data/repositories/appointment_repository.dart';
import 'package:hospital_management/data/repositories/providers/appointment_repository_provider.dart';

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AsyncValue<List<Appointment>>>(
        (ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentNotifier(repository);
});

class AppointmentNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  final AppointmentRepository _repository;

  AppointmentNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final appointments = await _repository.getAllAppointments();
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      await _repository.saveAppointment(appointment);
      await loadAppointments();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _repository.updateAppointment(appointment);
      await loadAppointments();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _repository.deleteAppointment(id);
      await loadAppointments();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<Appointment>> getAppointmentsByPatientId(String patientId) async {
    try {
      return await _repository.getAppointmentsByPatientId(patientId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }

  Future<List<Appointment>> getAppointmentsByDoctorId(String doctorId) async {
    try {
      return await _repository.getAppointmentsByDoctorId(doctorId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      return await _repository.getAppointmentsByDate(date);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }
}
