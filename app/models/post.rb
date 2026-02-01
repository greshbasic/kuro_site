class Post < ApplicationRecord
  has_one_attached :image

  validates :title, :body, :post_date, presence: true

  before_save :render_html_content

  private

  def render_html_content
    # Convert markdown image paths to asset paths before rendering
    processed_body = body.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do
      alt = $1
      path = $2
      "![#{alt}](#{ActionController::Base.helpers.asset_path(path)})"
    end
    self.html_content = Kramdown::Document.new(processed_body).to_html
  end
end
