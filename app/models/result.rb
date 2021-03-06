class Result < ActiveRecord::Base
  has_many  :tasks

  validates :score,      presence: true
  # challenger => ネームエントリー
  validates :challenger, presence: true,
                         length: { is: 3 }

  class << self
    def find_or_create(session)
      session.present? ? find(session) : prepare
    end

    # TODO activerecord-importによる高速化
    def prepare
      result = create
      tasks = []
      10.times do
        task = Task.new(
          # name: Takarabako.open,
          name: Task::CANDIDATE.sample,
          state: [*0..4].sample,
          category: [*0..Task.categories.count - 1].sample,
          result: result,
        )
        tasks << task
      end
      Task.import tasks
      result
    end
  end
end
