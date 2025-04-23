class OptionVotesController < ApplicationController
  def create
    @vote = OptionVote.new(vote_params)
    @vote.user = Current.session.user
    delete_count = 0

    save_result = OptionVote.transaction do
      delete_count = OptionVote.where(user_id: Current.session.user.id, poll_id: @vote.poll.id).delete_all
      @vote.save
    end

    respond_to do |format|
      if save_result
        format.html { redirect_to @vote.poll, notice: "Vote was successfully #{delete_count > 0 ? "changed" : "added"}." }
        format.json { render :show, status: :created, location: @vote }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    option_vote = OptionVote
      .preload(:poll)
      .where(user_id: Current.session.user.id, option_id: params.expect(:option_id))
      .first!
    poll = option_vote.poll
    option_vote.destroy!

    respond_to do |format|
      format.html { redirect_to poll, status: :see_other, notice: "Vote was successfully removed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def vote_params
      params.expect(option_vote: [ :option_id, :poll_id ])
    end
end
