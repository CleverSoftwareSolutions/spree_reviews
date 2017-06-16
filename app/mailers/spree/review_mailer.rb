class Spree::ReviewMailer < Spree::BaseMailer
  layout 'spree/base_mailer'

  def review_notification_email(review)
    @review = review.respond_to?(:id) ? review : Spree::Review.find(review)
    send_to_address = Spree::Config[:mail_bcc]
    subject = "#{Spree::Store.current.name} New review on product #{@review.product.name}"
    mail(to: send_to_address, bcc: [], from: from_address, subject: subject)
  end

end