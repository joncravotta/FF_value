# weights a single player against opponent defense
class DefenseWeighted
  def initialize(defenses)
    @defenses = defenses
  end
  
  # weight calculation
  def weight(player)
    opponent = parse_opponent(player.game_info, player.team_abrev)
    defense_rank = defenses_rank(opponent)
    multiplier = player.avg_points_per_game.to_f * defense_rank.to_f
    multiplier / player.salary.to_f * 100
  end

  private
  def parse_opponent(game_info, team_abrev)
    index = game_info.index('@')
    first_team = game_info[index - 3..index - 1]
    second_team = game_info[index + 1..index + 3]
    team_abrev == first_team ? second_team : first_team
  end

  # gets index of team, teams are in rank order
  def defenses_rank(defense_abrev)
    @defenses.index(@defenses.find { |d| d.team_abrev == defense_abrev })
  end

end