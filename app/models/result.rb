class Result < ActiveRecord::Base
  has_many  :tasks

  validates :score,      presence: true
  # challenger => ネームエントリー
  validates :challenger, presence: true,
                         length: { is: 3 }
end
