ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define(version: 1) do
  create_table :articles do |t|
    t.string :title
    t.text   :description

    t.timestamps
  end

  create_table :comments do |t|
    t.references :article, index: true
    t.text       :message

    t.timestamps
  end

  create_table :likes do |t|
    t.references :article, index: true

    t.timestamps
  end

  create_table :shard_articles do |t|
    t.string :title
    t.text   :description

    t.timestamps
  end
end
