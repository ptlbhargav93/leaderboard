class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name
      t.text :address
      t.string :phone
      t.string :email
      t.date :joined_date
      t.boolean :active
      t.integer :ranking, default: 1000

      t.timestamps
    end
  end
end
