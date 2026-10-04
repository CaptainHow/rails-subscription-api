class CreatePaymentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_events do |t|
      t.string :stripe_event_id
      t.string :event_type
      t.jsonb :payload
      t.datetime :processed_at

      t.timestamps
    end
    add_index :payment_events, :stripe_event_id, unique: true
  end
end
