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

const Map<PostVisibility, String> visibilityToStringMap = {
  PostVisibility.public : "Público",
  PostVisibility.friendsOnly : "Apenas amigos",
  PostVisibility.private : "Privado",
};

const Map<String, PostVisibility> stringToVisibilityMap = {
  "Público" : PostVisibility.public,
  "Apenas amigos" : PostVisibility.friendsOnly,
  "Privado" : PostVisibility.private,
};