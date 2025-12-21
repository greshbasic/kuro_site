class RenameAuthorToInitialsInComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :author, :initials
  end
end