class ResultsController < ApplicationController

  def update
    result = Result.find(params[:id])
    result = result.update(result_params) ? result : nil
    render json: { result: result }
  end

  private

    def result_params
      params.require(:result).permit(:challenger)
    end
end
