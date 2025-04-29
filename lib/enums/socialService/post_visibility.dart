enum PostVisibility { public, friendsOnly, private }

const Map<int, PostVisibility> visibilityMap = {
  0: PostVisibility.public,
  1: PostVisibility.friendsOnly,
  2: PostVisibility.private,
};

const Map<PostVisibility, int> visibilityToIntMap = {
  PostVisibility.public : 0,
  PostVisibility.friendsOnly : 1,
  PostVisibility.private : 2,
};