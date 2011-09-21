class CallController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    Call.parse_string params[:num]
  end
end
