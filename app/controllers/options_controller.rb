class OptionsController < ApplicationController
  include PollDetails
  before_action :set_option, only: %i[ destroy ]

  def destroy
    poll = @option.poll
    @option.destroy!

    respond_to do |format|
      format.html { redirect_to poll, status: :see_other, notice: "Option was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def create
    @option = Option.new(option_params)
    # require the poll to exist and be owned by the current user
    @poll = Poll.where(id: @option.poll_id, user_id: Current.session.user.id).first!
    @option.user = Current.session.user

    respond_to do |format|
      if @option.save
        format.html { redirect_to @poll, notice: "Option was successfully created." }
        format.json { render :show, status: :created, location: @option }
      else
        format.html {
          load_show_details(@option.poll_id)
          render "polls/show", status: :unprocessable_entity
        }
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_option
      @option = Option.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def option_params
      params.expect(option: [ :content, :poll_id ])
    end
end
