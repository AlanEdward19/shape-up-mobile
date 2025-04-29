enum ReactionType {
  like,
  dislike,
  love,
  haha,
  wow,
  sad,
  angry,
  care,
  support,
  celebrate,
}

const Map<ReactionType, int> reactionTypeMap = {
  ReactionType.like : 0,
  ReactionType.dislike : 1,
  ReactionType.love : 2,
  ReactionType.haha : 3,
  ReactionType.wow : 4,
  ReactionType.sad : 5,
  ReactionType.angry : 6,
  ReactionType.care : 7,
  ReactionType.support : 8,
  ReactionType.celebrate : 9,
};

const Map<int, ReactionType> intReactionTypeMap = {
  0: ReactionType.like,
  1: ReactionType.dislike,
  2: ReactionType.love,
  3: ReactionType.haha,
  4: ReactionType.wow,
  5: ReactionType.sad,
  6: ReactionType.angry,
  7: ReactionType.care,
  8: ReactionType.support,
  9: ReactionType.celebrate,
};

const Map<ReactionType, String> reactionEmojiMap = {
  ReactionType.like: "👍",
  ReactionType.dislike: "👎",
  ReactionType.love: "❤️",
  ReactionType.haha: "😄",
  ReactionType.wow: "😮",
  ReactionType.sad: "😢",
  ReactionType.angry: "😠",
  ReactionType.care: "🤗",
  ReactionType.support: "💪",
  ReactionType.celebrate: "🎉"
};