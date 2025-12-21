class Comment < ApplicationRecord
  validates :initials, presence: true, length: { maximum: 3 }
  validates :body, presence: true
end
