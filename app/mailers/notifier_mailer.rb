class NotifierMailer < ApplicationMailer
  def new_post(post_name)
    @link = "https://kuro-site.onrender.com/blog/#{post_name}"

    ENV['BLOG_SUBSCRIBERS'].split(",").each do |subscriber|
      Rails.logger.info "Sending new post email to #{subscriber}"
      mail(
        to: subscriber,
        subject: 'NEW KURO POST',
      )
    end
  end
end
