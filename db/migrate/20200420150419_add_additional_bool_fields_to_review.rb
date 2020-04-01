class AddAdditionalBoolFieldsToReview < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_reviews, :agree_to_share
    add_column :spree_reviews, :share_brand_site, :boolean, default: false
    add_column :spree_reviews, :share_ecom_site, :boolean, default: false
    add_column :spree_reviews, :share_social, :boolean, default: false
    add_column :spree_reviews, :share_all, :boolean, default: false
  end
end
