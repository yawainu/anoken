class TasksController < ApplicationController

  def index
    if cookies[:playing].present? && cookies[:result_id].blank?
      flash[:danger] = "トラブル発生"
      cookies.delete(:playing)
      redirect_to root_path and return
    end
    cookies.permanent[:playing] = true
    @result = Result.find_or_create(cookies[:result_id])
    @tasks = @result.tasks.group_by(&:state)
    if cookies[:result_id].blank?
      cookies[:result_id] = {
        value: @result.id,
        expires: 60.days.from_now
      }
    end
  end

  def update
    task = Task.find(params[:id])
    data =
      if continuable = cookies[:result_id].present?
        score = {score: task.evaluate(task_params) ? task.result.score : nil}
        params[:input].present? ? score.merge({task: task}) : score
      else
        cookies.delete(:playing)
        cookies[:finished_id] = { value: task.result.id, expires: 5.minutes.from_now }
        {}
      end
    render json: {continuable: continuable}.merge(data)
  end

  def expired
    if cookies[:finished_id].blank?
      redirect_to root_path and return
    end
    @result = Result.find(cookies[:finished_id])
    @results = Result.order(score: :desc).first(10)
    flash.now[:danger] = "hogehoge！"
  end

  private

    def task_params
      params.require(:task).permit(
        %i(name state category priority comment)
      )
    end
end
