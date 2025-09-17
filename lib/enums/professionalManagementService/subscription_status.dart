enum SubscriptionStatus{
  Active,
  Cancelled,
  Expired
}

Map <int, SubscriptionStatus> subscriptionStatusMap = {
  0: SubscriptionStatus.Active,
  1: SubscriptionStatus.Cancelled,
  2: SubscriptionStatus.Expired
};

SubscriptionStatus subscriptionStatusFromInt(int value) {
  return subscriptionStatusMap[value] ?? SubscriptionStatus.Expired;
}

int subscriptionStatusToInt(SubscriptionStatus status) {
  return subscriptionStatusMap.entries.firstWhere(
    (entry) => entry.value == status,
    orElse: () => MapEntry(2, SubscriptionStatus.Expired), // Default to Expired
  ).key;
}