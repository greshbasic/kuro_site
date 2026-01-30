class Post < ApplicationRecord
  validates :title, :body, :post_date, presence: true
end
