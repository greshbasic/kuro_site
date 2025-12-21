class Respect < ApplicationRecord
  after_initialize do
    self.count ||= 0
  end

  def self.instance
    first_or_create!(count: 0)
  end
end
