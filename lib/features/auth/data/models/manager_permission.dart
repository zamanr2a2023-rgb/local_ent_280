enum ManagerPermission {
  viewTrips('vt'),
  viewReports('vr'),
  viewAudit('va'),
  viewDrivers('vd'),
  viewClients('vc'),
  viewSupportRequests('vs'),
  manageClientChats('ch'),
  cancelTripBySupport('cs'),
  updateTripSupport('ts'),
  resolvePasswordHelpRequest('rp'),
  manageEvents('me'),
  assignVehicleToDriver('av'),
  editDriverStatus('ed'),
  manageTariffs('mt'),
  manageTripPackages('tp');

  const ManagerPermission(this.code);

  final String code;

  static ManagerPermission? fromCode(String code) {
    for (final permission in ManagerPermission.values) {
      if (permission.code == code) {
        return permission;
      }
    }
    return null;
  }
}

Map<ManagerPermission, bool> managerPermissionsFromFirestore(
  Map<String, dynamic>? raw,
) {
  final source = raw ?? const <String, dynamic>{};
  return {
    for (final permission in ManagerPermission.values)
      permission: source[permission.code] == true,
  };
}

bool managerPermissionsAreConfigured(Map<String, dynamic>? raw) {
  final source = raw ?? const <String, dynamic>{};
  return source.keys.any((key) => ManagerPermission.fromCode(key) != null);
}
