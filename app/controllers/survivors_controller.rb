class SurvivorsController < ApplicationController
  def index
    @survivors = Survivor.all
  end

  def show
    @survivor = Survivor.find(params[:id])
  end

  def new
    @survivor = Survivor.new
  end

  def edit
    @survivor = Survivor.find(params[:id])
  end

  def create
    @survivor = Survivor.new(create_survivor_params)

    if @survivor.save
    else
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
    else
    end
  end

  def destroy
  end

  def show_percentage_abducted
    @survivors = Survivor.find(flagging_params)
  end

  private

  def create_survivor_params
    params.require(:survivor).permit(:name, :age, :gender)
  end

  def update_location_params
    params.require(:survivor).permit(:latitude, :longitude)
  end

  def flagging_params
    params.require(:survivor).permit(:number_of_flags)
  end
end
