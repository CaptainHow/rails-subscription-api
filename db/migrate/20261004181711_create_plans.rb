class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :stripe_price_id
      t.integer :amount_cents
      t.string :interval
      t.boolean :active

      t.timestamps
    end
  end
end
