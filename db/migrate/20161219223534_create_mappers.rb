class CreateMappers < ActiveRecord::Migration[5.0]
  def change
    create_table :mappers, id: :uuid do |t|
      t.uuid :user_id
    end
    add_index :mappers, :user_id
  end
end
