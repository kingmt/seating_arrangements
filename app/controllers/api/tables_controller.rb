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
  # this isn't complicated at all
  def update
    # given an array of people ids
    if params[:people] && params[:people].is_a?(Array)
      people = params['people'].collect{|id| Person.find_by id: id.to_i }.compact
      if people.size == params[:people].size
        seated_people = people.select{|p| p.seated && p.seat.table_id != @table.id}
        if seated_people.empty?
          seats = people.collect{|p| Seat.new table: @table, person: p}
          if TableRules.check_table(seats).empty?
            @table.seats = seats
            @table.save
            render json: @table
          else
            render json: {errors: "Unable to seat those people in that order"}, status: 422
          end
        else
          has_have = if seated_people.size > 1
                       'have'
                     else
                       'has'
                     end
          render json: {errors: "#{seated_people.collect(&:name).sort.to_sentence} #{has_have} already been seated at another table"}, status: 422
        end
      else
        render json: {errors: "Non-existant people sent"}, status: 422
      end
    else
      render json: {errors: 'Invalid parameters'}, status: 422
    end
  end

  # DELETE /api/tables/:id
  def destroy
    @table.destroy
    head :no_content
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
