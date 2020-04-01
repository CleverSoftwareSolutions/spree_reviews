class AddAttachementToReviews < ActiveRecord::Migration[5.1]
  def change
    add_attachment :spree_reviews, :image
    add_index :spree_reviews, :token, unique: true
  end
end
