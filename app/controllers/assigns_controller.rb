class AssignsController < ApplicationController
  before_action :authenticate_user!

  def create
    team = Team.friendly.find(params[:team_id])
    user = email_reliable?(assign_params) ? User.find_or_create_by_email(assign_params) : nil
    if user
      team.invite_member(user)
      redirect_to team_url(team), notice: I18n.t('views.messages.assigned')
    else
      redirect_to team_url(team), notice: I18n.t('views.messages.failed_to_assign')
    end
  end

  def destroy
    assign = Assign.find(params[:id])
    destroy_message = assign_destroy(assign, assign.user)

    redirect_to team_url(params[:team_id]), notice: destroy_message
  end

  def update
    team = Team.friendly.find(team_params)
    if current_user.id == team.owner_id
      assign = Assign.find(params[:id])
      team.owner_id = assign.user_id
      if team.save
        user = User.find(assign.user_id)
        redirect_to team_url(team), notice: '権限を移譲しました。'
      else
        redirect_to team_url(team), notice: '権限移譲にできませんでした。'
      end
    else
      redirect_to team_url(team), notice: '権限移動はリーダーしか出来ません'
    end
  end

  private

  def assign_params
    params[:email]
  end

  def team_params
    params[:team_id]
  end

  def assign_destroy(assign, assigned_user)
    if assigned_user == assign.team.owner
      I18n.t('views.messages.cannot_delete_the_leader')
    elsif Assign.where(user_id: assigned_user.id).count == 1
      I18n.t('views.messages.cannot_delete_only_a_member')
    elsif assigned_user != current_user && current_user != assign.team.owner
      "削除権限はリーダーまたはメンバー本人のみ有します。"
    elsif assign.destroy
      set_next_team(assign, assigned_user)
      I18n.t('views.messages.delete_member')
    else
      I18n.t('views.messages.cannot_delete_member_4_some_reason')
    end
  end
  
  def email_reliable?(address)
    address.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end
  
  def set_next_team(assign, assigned_user)
    another_team = Assign.find_by(user_id: assigned_user.id).team
    change_keep_team(assigned_user, another_team) if assigned_user.keep_team_id == assign.team_id
  end
end
