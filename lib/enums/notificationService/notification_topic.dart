enum NotificationTopic {
  Message,
  FriendRequest,
  Reaction,
  NewFollower,
  Comment
}

Map<int, NotificationTopic> notificationTopicMap = {
  0: NotificationTopic.Message,
  1: NotificationTopic.FriendRequest,
  2: NotificationTopic.Reaction,
  3: NotificationTopic.NewFollower,
  4: NotificationTopic.Comment
};