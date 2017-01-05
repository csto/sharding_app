class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid
      t.string :name

      t.timestamps
    end
  end
end
