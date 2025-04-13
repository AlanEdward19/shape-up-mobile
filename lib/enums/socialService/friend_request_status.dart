enum FriendRequestStatus { Pending, PendingResponse }

const Map<int, FriendRequestStatus> friendRequestStatusMap = {
  0: FriendRequestStatus.Pending,
  1: FriendRequestStatus.PendingResponse,
};