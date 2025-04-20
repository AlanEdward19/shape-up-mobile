enum PostVisibility { public, friendsOnly, private }

const Map<int, PostVisibility> visibilityMap = {
  0: PostVisibility.public,
  1: PostVisibility.friendsOnly,
  2: PostVisibility.private,
};