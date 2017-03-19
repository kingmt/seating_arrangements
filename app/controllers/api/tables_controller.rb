class Api::TablesController < ApiController
  before_action :set_table, only: [:show, :update, :destroy]

  # GET /api/tables
  def index
    @tables = Table.all
    render json: @tables
  end

  # POST /api/tables
  def create
    @table = Table.create
    render json: @table
  end

  # GET /api/tables/:id
  def show
    render json: @table
  end

  # PUT /api/tables/:id
  # update everyone at the table
  def update
    # do some work
    render json: @table
  end

  # DELETE /api/tables/:id
  def destroy
    @table.destroy
    render json: @table
  end

  private
    def set_table
      if @table = Table.find_by(id: params[:id])
        # continue
      else
        render json: {errors: 'Table does not exist'}, status: 404
        # stop processing
        false
      end
    end
end
