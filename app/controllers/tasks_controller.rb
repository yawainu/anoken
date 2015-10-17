class TasksController < ApplicationController

  def index
    if request.referer.blank? && session[:result_id].blank?
      flash.now[:danger] == "トラブル発生"
      redirect_to root_path and return
    end
    @result = Result.find_or_create(session[:result_id])
    @tasks = @result.tasks.order('tasks.state asc')
    session[:result_id] = @result.id if session[:result_id].blank?
  end

  def update
    task = Task.find(params[:id])
    data =
      if expired = session[:result_id].present?
        {task: task.evaluate(task_params) ? task : nil}
      else
        {result_id: task.result.id}
      end
    render json: {expired: expired}.merge(data)
  end

  def expired
    @result = Result.find(params[:id])
  end

  private

    def task_params
      params.require(:task).permit(
        %i(name state category priority comment)
      )
    end
end
