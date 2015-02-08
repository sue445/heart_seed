class Article < ActiveRecord::Base
  establish_connection(:test)
end

class Comment < ActiveRecord::Base
  establish_connection(:test)

  validates_numericality_of :article_id, greater_than: 0
end

class Like < ActiveRecord::Base
  establish_connection(:test)
end

class ShardArticle < ActiveRecord::Base
  establish_connection(:shard_test)
end

