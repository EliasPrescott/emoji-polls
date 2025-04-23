class PollsController < ApplicationController
  include PollDetails
  before_action :set_poll, only: %i[ edit update destroy ]

  # GET /polls/1
  def show
    load_show_details(params.expect(:id))
    @option = Option.new
    @option.poll = @poll
  end

  # GET /polls/new
  def new
    @poll = Poll.new
    @poll.user = Current.session.user
  end

  # GET /polls/1/edit
  def edit
  end

  # POST /polls
  def create
    @poll = Poll.new(poll_params)
    @poll.user = Current.session.user

    if @poll.save
      redirect_to @poll, notice: "Poll was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /polls/1
  def update
    if @poll.update(poll_params)
      redirect_to @poll, notice: "Poll was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /polls/1
  def destroy
    @poll.destroy!

    redirect_to root_path, status: :see_other, notice: "Poll was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def poll_params
      params.expect(poll: [ :title ])
    end
end
