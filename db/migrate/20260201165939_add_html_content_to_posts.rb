class AddHtmlContentToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :html_content, :text
  end
end
