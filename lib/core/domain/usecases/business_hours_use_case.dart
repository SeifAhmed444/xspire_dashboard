class BusinessHoursUseCase {
  const BusinessHoursUseCase();

  bool isCurrentlyOpen() {
    final now = DateTime.now();
    final openHour = 12;  
    final closeHour = 24;  
    return now.hour >= openHour && now.hour < closeHour;
  }

  String statusLabel() {
    return isCurrentlyOpen() ? 'Open' : 'Closed';
  }
}