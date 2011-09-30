class CallsController < ApplicationController
  def index
    @calls = Call.paginate(:page => params[:page])
  end

  def show
    @call = Call.find_by_id params[:id]
  end

  def new
    @call = Call.new
  end

  def create
    Call.parse_string params[:num]
    redirect_to calls_path
  end
end
