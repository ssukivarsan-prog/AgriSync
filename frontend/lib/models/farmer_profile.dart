class FarmerProfile {
  final String name;
  final String location;
  final String preferredLanguage;
  final String farmingExperience; // e.g. "5-10 Years", "Beginner", "Experienced"
  final String farmName;
  final double farmSizeAcres;
  final String soilType; // "Loamy", "Sandy Loam", "Clay Loam", "Black Soil"
  final String irrigationAvailability; // "Drip Irrigation", "Canal/Furrow", "Sprinkler", "Rainfed"
  final String waterAvailability; // "Ample / Borewell", "Moderate", "Scarce / Seasonal"
  final String previousCrop; // "Groundnut", "Rice", "Cotton", "Maize", "Fallow"
  final String currentSeason; // "Samba", "Kuruvai", "Thaladi", "Navarai", "Kharif", "Rabi"
  final String districtTamilNadu;
  final String agroClimaticZone;
  final String phoneNumber;

  FarmerProfile({
    this.name = "Murugan Selvam",
    this.location = "Thanjavur, Tamil Nadu",
    this.preferredLanguage = "English / தமிழ்",
    this.farmingExperience = "14 Years",
    this.farmName = "Cauvery Delta Smart Farm",
    this.farmSizeAcres = 8.5,
    this.soilType = "Cauvery Alluvial Clay Loam",
    this.irrigationAvailability = "Canal & Borewell Drip",
    this.waterAvailability = "Ample (River Canal + Borewell)",
    this.previousCrop = "Paddy (Kuruvai)",
    this.currentSeason = "Samba Season",
    this.districtTamilNadu = "Thanjavur",
    this.agroClimaticZone = "Cauvery Delta Agro-Climatic Zone",
    this.phoneNumber = "+91 98421 78210",
  });

  FarmerProfile copyWith({
    String? name,
    String? location,
    String? preferredLanguage,
    String? farmingExperience,
    String? farmName,
    double? farmSizeAcres,
    String? soilType,
    String? irrigationAvailability,
    String? waterAvailability,
    String? previousCrop,
    String? currentSeason,
    String? districtTamilNadu,
    String? agroClimaticZone,
    String? phoneNumber,
  }) {
    return FarmerProfile(
      name: name ?? this.name,
      location: location ?? this.location,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      farmName: farmName ?? this.farmName,
      farmSizeAcres: farmSizeAcres ?? this.farmSizeAcres,
      soilType: soilType ?? this.soilType,
      irrigationAvailability: irrigationAvailability ?? this.irrigationAvailability,
      waterAvailability: waterAvailability ?? this.waterAvailability,
      previousCrop: previousCrop ?? this.previousCrop,
      currentSeason: currentSeason ?? this.currentSeason,
      districtTamilNadu: districtTamilNadu ?? this.districtTamilNadu,
      agroClimaticZone: agroClimaticZone ?? this.agroClimaticZone,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
