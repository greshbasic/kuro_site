class NotifierMailer < ApplicationMailer
  def new_post(post_name)
    @link = "https://kuro-site.onrender.com/blog/#{post_name}"
    @title = post_name.split('_', 2)[1]
    @title = @title[0..-4].tr('_', ' ').titleize

    subscribers = ENV['BLOG_SUBSCRIBERS'].split(',').map(&:strip)
    date = post_name.split('_', 2)[0]
    subject = "NEW KURO POST (#{date})"

    mail(bcc: subscribers, subject:)
  end

  def new_db_post(post)
    @link = "https://kuro-site.onrender.com/blog/db_#{post.id}"
    @title = post.title

    subscribers = ENV['BLOG_SUBSCRIBERS'].split(',').map(&:strip)
    date = post.post_date.strftime('%Y-%m-%d')
    subject = "NEW KURO POST (#{date})"

    mail(bcc: subscribers, subject:)
  end
end
