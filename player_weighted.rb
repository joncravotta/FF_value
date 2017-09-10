WeightedPlayer = Struct.new(:info, :name, :weight)

# takes seperated players by position and runs each
# players through the weighted defens and writes out to
# a txt file
class PlayersWeighted
  def initialize(all_players)
    @players = all_players
    @defense_weighted = WeightPlayerAgainstDefense.new(all_players.dst)
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
      if player.game_info != "Postponed"
        w = @defense_weighted.weight(player)
        wp = WeightedPlayer.new(player, player.name, w)
        weighted.push(wp)
      end
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