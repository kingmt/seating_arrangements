class Api::PeopleController < ApiController
  before_action :set_person, only: [:show, :update, :destroy]

  # GET /api/people
  def index
    @people = Person.all
    render json: @people
  end

  # POST /api/people
  def create

    @person = Person.new(person_params)
    if @person.valid?
      @person.save
      render json: @person
    else
      render json: {errors: @person.errors.full_messages}, status: 422
    end
  end

  # GET /api/people/:id
  def show
    render json: @person
  end

  # PUT /api/people/:id
  # seated people are ineligible to be updated
  def update
    if @person.seat
      render json: {errors: 'Cannot update a seated person'}, status: 422
    else
      @person.update person_params
      render json: @person
    end
  end

  # DELETE /api/people/:id
  def destroy
    if @person.seat
      # seated people are ineligible to be deleted
      render json: {errors: 'Cannot delete a seated person'}, status: 422
    else
      @person.destroy
      render nothing: true, status: 204
    end
  end

  private

    def person_params
      params.require(:person).permit :name, :age
    end

    def set_person
      if @person = Person.find_by(id: params[:id])
        # continue
      else
        render json: {errors: 'Person does not exist'}, status: 404
        # stop processing
        false
      end
    end
end

