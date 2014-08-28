class Article < ActiveRecord::Base
  establish_connection(:test)
end

class Comment < ActiveRecord::Base
  establish_connection(:test)
end

class Like < ActiveRecord::Base
  establish_connection(:test)
end

class ShardArticle < ActiveRecord::Base
  establish_connection(:shard_test)
end

