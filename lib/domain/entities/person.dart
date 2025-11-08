abstract class Person {
  final String _name;
  final String _dateOfBirth;
  final String _address;
  final String _tel;

  String get name => _name;
  String get dateOfBirth => _dateOfBirth;
  String get address => _address;
  String get tel => _tel;

  Person({
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
  })  : _name = name,
        _dateOfBirth = dateOfBirth,
        _address = address,
        _tel = tel {
    _validatePerson();
  }

  void _validatePerson() {
    if (_name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (_address.trim().isEmpty) {
      throw ArgumentError('Address cannot be empty');
    }
    _validatePhoneNumber(_tel);
    _validateDateOfBirth(_dateOfBirth);
  }

  void _validatePhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      throw ArgumentError('Invalid phone number format');
    }
  }

  void _validateDateOfBirth(String date) {
    try {
      final birthDate = DateTime.parse(date);
      if (birthDate.isAfter(DateTime.now())) {
        throw ArgumentError('Date of birth cannot be in the future');
      }
    } catch (e) {
      throw ArgumentError('Invalid date format for date of birth');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _dateOfBirth == other._dateOfBirth &&
          _tel == other._tel;

  @override
  int get hashCode => _name.hashCode ^ _dateOfBirth.hashCode ^ _tel.hashCode;

  @override
  String toString() => '${runtimeType}(name: $_name, tel: $_tel)';
}
