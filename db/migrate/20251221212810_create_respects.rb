class CreateRespects < ActiveRecord::Migration[8.0]
  def change
    create_table :respects do |t|
      t.integer :count

      t.timestamps
    end
  end
end
