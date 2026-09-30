enum LoginType {
  dummyJson,
  firebase;

  String get label => switch (this) {
    LoginType.dummyJson => 'DummyJSON',
    LoginType.firebase => 'Firebase',
  };

  static LoginType fromStorage(String? value) => LoginType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => LoginType.dummyJson,
  );
}
