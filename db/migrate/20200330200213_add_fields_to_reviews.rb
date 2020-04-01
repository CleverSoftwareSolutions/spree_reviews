class AddFieldsToReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_reviews, :agree_to_share, :boolean, default: false
    add_column :spree_reviews, :order_id, :integer, null: true
    add_column :spree_reviews, :token, :string, null: true
  end
end
