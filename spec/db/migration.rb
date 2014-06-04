ActiveRecord::Schema.verbose = false

ActiveRecord::Base.configurations["test"] = {
    adapter:  "sqlite3",
    database: ":memory:",
    timeout:  500
}

ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["test"])

ActiveRecord::Schema.define(version: 1) do
  create_table :articles do |t|
    t.string :title
    t.text   :description

    t.timestamps
  end
end
