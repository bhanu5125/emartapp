module.exports = {
  mongoURI: process.env.MONGO_URI || "mongodb://emongo:27017/epoc",
  secretOrKey: process.env.JWT_SECRET
};
