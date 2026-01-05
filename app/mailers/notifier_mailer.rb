class NotifierMailer < ApplicationMailer
  def new_post(post_name)
    @link = "https://kuro-site.onrender.com/blog/#{post_name}"

    subscribers = ENV['BLOG_SUBSCRIBERS'].split(',').map(&:strip)

    mail(bcc: subscribers, subject: 'NEW KURO POST')
  end
end
