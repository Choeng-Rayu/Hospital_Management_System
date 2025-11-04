import 'local/json_data_source.dart';
import '../models/bed_model.dart';

/// Local data source for Bed entity
/// Provides specialized queries for bed data
class BedLocalDataSource extends JsonDataSource<BedModel> {
  BedLocalDataSource()
      : super(
          fileName: 'beds.json',
          fromJson: BedModel.fromJson,
        );

  /// Find a bed by bed number
  Future<BedModel?> findByBedNumber(String bedNumber) {
    return findById(
      bedNumber,
      (bed) => bed.bedNumber,
      (bed) => bed.toJson(),
    );
  }

  /// Check if a bed exists
  Future<bool> bedExists(String bedNumber) {
    return exists(bedNumber, (bed) => bed.bedNumber);
  }

  /// Find beds by IDs
  Future<List<BedModel>> findBedsByIds(List<String> bedIds) async {
    if (bedIds.isEmpty) return [];
    final allBeds = await readAll();
    return allBeds.where((bed) => bedIds.contains(bed.bedNumber)).toList();
  }

  /// Find occupied beds
  Future<List<BedModel>> findOccupiedBeds() {
    return findWhere((bed) => bed.isOccupied);
  }

  /// Find available beds
  Future<List<BedModel>> findAvailableBeds() {
    return findWhere((bed) => !bed.isOccupied);
  }

  /// Find bed by patient ID
  Future<BedModel?> findBedByPatientId(String patientId) async {
    final beds = await findWhere((bed) => bed.currentPatientId == patientId);
    return beds.isEmpty ? null : beds.first;
  }

  /// Find beds by type
  Future<List<BedModel>> findBedsByType(String bedType) {
    return findWhere((bed) => bed.bedType == bedType);
  }
}
