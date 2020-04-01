class Spree::Review < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :user, class_name: Spree.user_class.to_s
  belongs_to :order, class_name: Spree::Order
  has_many   :feedback_reviews

  before_save :set_order_id_from_token, if: :token_changed?
  after_save :recalculate_product_rating, if: :approved?
  after_destroy :recalculate_product_rating

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment :image,
    content_type: { content_type: %w(image/jpeg image/jpg image/png image/gif) }

  validates :name, :review, presence: true
  validates :rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    message: Spree.t(:you_must_enter_value_for_rating)
  }

  validates :token, :allow_nil => true,
                    :uniqueness => true
  validate :valid_token

  default_scope { order('spree_reviews.created_at DESC') }

  scope :localized, ->(lc) { where('spree_reviews.locale = ?', lc) }
  scope :most_recent_first, -> { order('spree_reviews.created_at DESC') }
  scope :oldest_first, -> { reorder('spree_reviews.created_at ASC') }
  scope :preview, -> { limit(Spree::Reviews::Config[:preview_size]).oldest_first }
  scope :approved, -> { where(approved: true) }
  scope :not_approved, -> { where(approved: false) }
  scope :default_approval_filter, -> { Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved }

  def feedback_stars
    return 0 if feedback_reviews.size <= 0
    ((feedback_reviews.sum(:rating) / feedback_reviews.size) + 0.5).floor
  end

  def recalculate_product_rating
    product.recalculate_rating if product.present?
  end

  private
  def decoded_token
    @decoded_token ||= JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
  end

  def valid_token
    return true unless Spree::Reviews::Config[:require_token]

    begin
      if token.blank?
        errors.add(:token, :token_missing)
      end

      if decoded_token.try(:[], "product_id") != product_id
        errors.add(:token, :product_not_matching)
      end
    rescue JWT::ExpiredSignature
      errors.add(:token, :token_expired)
    rescue JWT::DecodeError
      errors.add(:token, :invalid_token)
    end
  end

  def set_order_id_from_token
    self.order_id = decoded_token.try(:[], "order_id")
  end
end
