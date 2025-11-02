import '../entities/administrative.dart';

/// Repository interface for Administrative staff entity
/// Defines all data operations needed for administrative staff management
abstract class AdministrativeRepository {
  Future<Administrative> getAdministrativeById(String staffId);

  Future<List<Administrative>> getAllAdministrative();

  Future<void> saveAdministrative(Administrative administrative);

  Future<void> updateAdministrative(Administrative administrative);

  Future<void> deleteAdministrative(String staffId);

  Future<List<Administrative>> searchAdministrativeByName(String name);

  Future<List<Administrative>> getAdministrativeByResponsibility(
    String responsibility,
  );

  Future<bool> administrativeExists(String staffId);
}
