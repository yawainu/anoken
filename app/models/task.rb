class Task < ActiveRecord::Base
  belongs_to :result

  validates  :result_id, presence: true
  validates  :name,      presence: true,
                         length: { maximum: 100 }
  validates  :state,     presence: true
  validates  :touched,   presence: true
  validates  :category,  presence: true
  validates  :priority,  presence: true
  validates  :comment,   length: { maximum: 5000 },
                         if: :comment?

  enum :state,    %i(notouch inprogress
                     waiting postpone
                     pending done deleted).freeze
  enum :category, %i(contact report confirm
                     check contract cancel
                     deliver).freeze
  enum :priority, %i(top high middle row).freeze
end
