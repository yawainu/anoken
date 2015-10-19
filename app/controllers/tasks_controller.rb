class TasksController < ApplicationController

  def index
    # TODO なんかうまくいかない
    # if session[:result_id].blank? && request.path_info.blank? == session[:ref]
    #   flash.now[:danger] = "トラブル発生"
    #   redirect_to root_path and return
    # end
    @result = Result.find_or_create(session[:result_id])
    @tasks = @result.tasks.order('tasks.state asc')
    # session[:ref] = request.path_info
    cookies[:result_id] = { value: @result.id, 
                            expires: 60.seconds.from_now } if
                          cookies[:result_id].blank?
  end

  def update
    task = Task.find(params[:id])
    data =
      if continuable = cookies[:result_id].present?
        {score: task.evaluate(task_params) ? task.result.score : nil}
      else
        {result_id: task.result.id}
      end
    render json: {continuable: continuable}.merge(data)
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
