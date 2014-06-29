class Article < ActiveRecord::Base
  self.establish_connection(:test)
end

class Comment < ActiveRecord::Base
  self.establish_connection(:test)
end

class Like < ActiveRecord::Base
  self.establish_connection(:test)
end

class ShardArticle < ActiveRecord::Base
  self.establish_connection(:shard_test)
end

