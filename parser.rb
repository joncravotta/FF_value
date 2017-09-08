Player = Struct.new(:position, :name, :salary, :game_info, :avg_points_per_game, :team_abrev)

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