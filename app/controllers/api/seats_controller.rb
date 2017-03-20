class Api::SeatsController < ApiController
  before_action :set_table
  before_action :set_seat, only: [:update, :destroy]
  before_action :set_person, only: [:create]

  # POST /api/tables/:table_id/seats
  # 2 modes, autoplace and specified
  def create
    if params[:position]
      new_seat = Seat.new table: @table, person: @person
      if TableRules.place!(@table.seats.to_a, new_seat, params[:position].to_i)
        # found a seat
        @table.reload
        render json: @table
      else
        render json: {errors: 'Person cannot be seated at that position'}, status: 422
      end
    else
      if TableRules.autoplace!(@table.seats.to_a, @person)
        # found a seat
        @table.reload
        render json: @table
      else
        render json: {errors: 'Person cannot be seated'}, status: 422
      end
    end
  end

  # PUT /api/tables/:table_id/seats/:id
  # change position
  def update
    if params[:position]
      if TableRules.move!(@table.seats.to_a, @seat, params[:position].to_i)
        # found a seat
        @table.reload
        render json: @table
      else
        render json: {errors: 'Person cannot be seated at that position'}, status: 422
      end
    else
      render json: {errors: 'Position is required'}, status: 422
    end
  end

  # DELETE /api/tables/:table_id/seats/:id
  def destroy
    if @seat.can_be_unseated
      @seat.destroy
      @table.reload
      render json: @table
    else
      render json: {errors: 'Cannot remove the seat, the table would be invalid'}, status: 422
    end
  end

  private
    def set_person
      if @person = Person.find_by(id: params[:person_id])
        if @person.seated
          render json: {errors: 'Person is already seated'}, status: 422
          # stop processing
          false
        else
          # continue
        end
      else
        render json: {errors: 'Person does not exist'}, status: 404
        # stop processing
        false
      end
    end

    def set_seat
      if @seat = Seat.find_by(id: params[:id])
        # continue
      else
        render json: {errors: 'Seat does not exist'}, status: 404
        # stop processing
        false
      end
    end

    def set_table
      if @table = Table.find_by(id: params[:table_id])
        # continue
      else
        render json: {errors: 'Table does not exist'}, status: 404
        # stop processing
        false
      end
    end
end
