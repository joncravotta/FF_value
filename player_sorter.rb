# takes parsed players from csv
# and sorts them based on positions

AllPlayers = Struct.new(:qbs, :rbs, :wrs, :tes, :dst)

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