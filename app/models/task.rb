class Task < ActiveRecord::Base

  CANDIDATE = %w(hoge hogehoge
                 fuga fugafuga
                 piyo piyopiyo)

  belongs_to :result

  validates  :result_id, presence: true
  validates  :name,      presence: true,
                         length: { maximum: 100 }
  validates  :state,     presence: true
  validates  :category,  presence: true
  validates  :comment,   length: { maximum: 5000 },
                         if: :comment?

  enum state:    %i(notouch inprogress
                    waiting postpone
                    pending done deleted).freeze
  enum category: %i(contact report confirm
                    check contract cancel
                    deliver).freeze

  def evaluate(params)
    assign_attributes(params)
    valid? ? score = 0 : (false and return)
    changes.each do |changed_column, values|
      score += calculate(changed_column, values)
    end
    result.update(score: result.score += score) if changed?
    params = params.merge({touched: true}) unless touched?
    update(params)
  end

  def calculate(target, values)
    score = column_for_attribute(target).type == :integer ? 500 : 1500
    score +=
      case target
      when "state"
        case values[1]
        when "deleted"
          - 5000
        when "done"
          800
        else
          case values[0]
          when "notouch"
            case values[1]
            when "inprogress", "waiting"
              500
            when "postpone", "pending"
              - 300
            end
          when "inprogress"
            case values[1]
            when "notouch"
              - 700
            when "waiting"
              200
            when "postpone", "pending"
              - 450
            end
          when "waiting"
            case values[1]
            when "notouch"
              - 600
            when "inprogress"
              350
            when "pending", "postpone"
              - 250
            end
          when "postpone", "pending"
            case values[1]
            when "notouch"
              - 600
            when "inprogress"
              450
            when "waiting"
              250
            when "postpone", "pending", 
              - 100
            end
          when "done"
            - 3000
          end
        end
      when "category"
        180
      when "name"
        (values[1].uniq_count - values[0].uniq_count) * 30
      when "comment"
        (values[1].uniq_count - values[0].uniq_count) * 100
      end
  end
end
