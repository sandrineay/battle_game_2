# frozen_string_literal: true

class BattlesController < ApplicationController #:nodoc:
  before_action :set_battle, only: :show
  before_action :set_players, only: %i[new create]

  def index
    @battles = Battle.all
  end

  def new
    @players_count = Player.count
    @battle = Battle.new
  end

  def create
    @battle = Battle.new(battle_params)
    if @battle.save
      AfterBattleService.new.update(@battle)
      redirect_to battle_path(@battle)
    else
      flash.now[:alert] = flash_alerts
      render :new
    end
  end

  def show
    @winner = @battle.winner unless @battle.draw
    @loser = @battle.loser unless @battle.draw
    @winner_score = @battle.winner_score unless @battle.draw
    @loser_score = @battle.loser_score unless @battle.draw
  end

  private

  def flash_alerts
    errors = @battle.errors.full_messages
    not_ok = "Player 2 can't be blank"
    ok = 'Please select two players'
    errors.map { |m| m.gsub(not_ok, ok) }.join(' - ')
  end

  def set_battle
    @battle = Battle.find(params[:id])
  end

  def set_players
    @players = Player.where('life_points > ?', 0.0).order(life_points: :desc)
  end

  def battle_params
    params.require(:battle).permit(:player_1_id, :player_2_id)
  end
end
