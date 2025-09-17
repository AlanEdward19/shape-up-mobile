enum NotificationTopic {
  Message,
  FriendRequest,
  Reaction,
  NewFollower,
  Comment
}

Map<int, NotificationTopic> notificationTopicMap = {
  1: NotificationTopic.Message,
  2: NotificationTopic.FriendRequest,
  3: NotificationTopic.Reaction,
  4: NotificationTopic.NewFollower,
  5: NotificationTopic.Comment
};