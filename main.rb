require 'csv'

Player = Struct.new(:position, :name, :salary, :game_info, :avg_points_per_game, :team_abrev)
AllPlayers = Struct.new(:qbs, :rbs, :wrs, :tes, :dst)
WeightedPlayer = Struct.new(:info, :name, :weight)

# parses players from csv
class Parser
  def initialize(csv_file)
    @file_name = csv_file
    @players = []
  end

  def parse
    CSV.foreach(File.path(@file_name)) do |r|
      player = Player.new(r[0], r[1], r[2], r[3], r[4], r[5])
      @players << player
    end

    @players
  end
end

# takes parsed players from csv
# and sorts them based on positions
class SortPlayers
  def initialize(players)
    @players = players
  end

  def sort
    wrs = []
    qbs = []
    tes = []
    rbs = []
    dst = []

    @players.each do |player|
      case player.position
      when "WR"
        wrs.push(player)
      when "QB"
        qbs.push(player)
      when "TE"
        tes.push(player)
      when "RB"
        rbs.push(player)
      when "DST"
        dst.push(player)
      end
    end

    AllPlayers.new(qbs, rbs, wrs, tes, dst)
  end
end

# weights a single player against opponent defense
class DefenseWeighted
  def initialize(defenses)
    @defenses = defenses
  end

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

# takes seperated players by position and runs each
# players through the weighted defens and writes out to
# a txt file
class PlayersWeighted
  def initialize(all_players)
    @players = all_players
    @defense_weighted = DefenseWeighted.new(all_players.dst)
  end

  def weight_and_write_to_file
    wrs = @players.wrs
    qbs = @players.qbs
    rbs = @players.rbs
    tes = @players.tes

    positions = [wrs, qbs, rbs, tes]
    weighted = []

    positions.each do |position|
      weighted.push(weight(position))
    end

    write(weighted)

  end

  private
  def weight(players)

    weighted = []

    players.each do |player|
      w = @defense_weighted.weight(player)
      wp = WeightedPlayer.new(player, player.name, w)
      weighted.push(wp)
    end

    weighted
  end

  def write(weighted_players)
    File.open('output.txt', 'w') { |file|
      weighted_players.each do |weighted|
        sorted = weighted.sort_by {|w| w.weight}
        sorted.reverse[0..40].each do |player|
          file.write("Name: #{player.name}, Pos: #{player.info.position}, team: #{player.info.team_abrev} game: #{player.info.game_info}, PPG: #{player.info.avg_points_per_game} Price: #{player.info.salary} Weight: #{player.weight} \n")
        end

        file.write("\n")
      end
     }
  end
end

# responsible for gluing all together
class Main
  def initialize
    @csv_file = "2017_week_1.csv"
  end

  def execute
    p = Parser.new(@csv_file)
    players = p.parse
    sorted = SortPlayers.new(players)
    w = PlayersWeighted.new(sorted.sort)
    w.weight_and_write_to_file
  end
end

Main.new.execute
