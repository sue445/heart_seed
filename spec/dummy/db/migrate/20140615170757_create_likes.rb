class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :article, index: true

      t.timestamps
    end
  end
end
