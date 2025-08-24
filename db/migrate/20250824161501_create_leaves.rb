class CreateLeaves < ActiveRecord::Migration[8.0]
  def change
    create_table :leaves do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :leave_type, null: false
      t.string :state, null: false, default: "pending"

      t.timestamps
    end
  end
end
