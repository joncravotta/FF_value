require 'csv'
require_relative './weight_player_against_defense.rb'
require_relative './parser.rb'
require_relative './player_sorter.rb'
require_relative './player_weighted.rb'

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
