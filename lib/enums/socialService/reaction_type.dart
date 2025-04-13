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