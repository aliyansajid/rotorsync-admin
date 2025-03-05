class UUIDMapping {
  static const String baseUUID = "0000XXXX-0000-1000-8000-00805f9b34fb";

  static final Map<String, String> services = {
    "00001809-0000-1000-8000-00805f9b34fb": "Health Thermometer",
    "0000181a-0000-1000-8000-00805f9b34fb": "Environmental Sensing",
    "0000180f-0000-1000-8000-00805f9b34fb": "Battery Service",
  };

  static final Map<String, String> characteristics = {
    "00002a6e-0000-1000-8000-00805f9b34fb": "Temperature",
    "00002a6f-0000-1000-8000-00805f9b34fb": "Humidity",
    "00002a19-0000-1000-8000-00805f9b34fb": "Battery Level",
  };

  static String expandUUID(String uuid) {
    if (uuid.length == 4) {
      return "0000$uuid-0000-1000-8000-00805f9b34fb";
    }
    return uuid;
  }

  static String getServiceName(String uuid) {
    String fullUUID = expandUUID(uuid.toLowerCase().trim());
    return services[fullUUID] ?? "Unknown Service";
  }

  static String getCharacteristicName(String uuid) {
    String fullUUID = expandUUID(uuid.toLowerCase().trim());
    return characteristics[fullUUID] ?? "Unknown Characteristic";
  }
}
