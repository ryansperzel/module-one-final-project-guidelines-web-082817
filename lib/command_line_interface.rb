require 'unirest'
require 'colorize'
require 'colorized_string'

# $p1 = ""
$players_array = []


def team_data
  response = Unirest.get "https://montanaflynn-fifa-world-cup.p.mashape.com/teams",
    headers:{
      "X-Mashape-Key" => "AYyq4yYeJLmshQdu0EvhtNVYVBRep1FSgP6jsnraZ5TInHi5VH",
      "accepts" => "json",
      "Accept" => "application/json"
    }
end

def create_teams
  i = 0
  while i < 222
    Team.create(:name => team_data.body[i]["title"])
    i += 1
  end
end

def welcome
  puts "Welcome to the World Cup!\n\n
  ░░░░░░▄███████████▀▀▀█▄▄░░░░░░░░
░░░░▄██████████▀░░░░░░░▀▀██▄░░░░
░░▄█▀▀▀▀▀▀▀██▀░░░░░░░░░░░░███▄░░
▄█▀░░░░░░░░░█▄░░░░░░░░░░░░░████░
▀░░░░░░░░░░░░█▄░░░░░░░░░░░▄█████
▄▄░░░░░░░░░░░░▀█▄▄▄▄▄▄░▄█▀▀░░▀██
███░░░░░░░░░░░█████████▀░░░░░░░▀
███▄░░░░░░░░▄███████████░░░░░░░░
████▄▄▄▄▄▄▄█████████████░░░░░░░░
███▀░░░░░░░█████████████░░░░░░░░
███░░░░░░░░░▀██████████▀▀▄░░░░░█
░░░░░░░░░░░░░░██████▀▀░░░░▀▄░▄██
█▄░░░░░░░░░░░▄█░░░░░░░░░░░░▄██▀░
░▀█▄░░░░░░░░░█░░░░░░░░░░░░███▀░░
░░░▀▀█▄▄▄▄▄▄██░░░░░░░░░░░██▀░░░░
░░░░░░░▀▀██████▄▄░░░░░▄▄█▀░░░░░░
\n\n"


  # puts "What is your name Player One?".colorize(:red)
  # $p1 = gets.chomp
  #
  # puts "\n\n\n\nWhat is yout name Player Two".colorize(:blue)
  # $p2 = gets.chomp

end

def player_count
  puts "How many players are playing?"
  response = gets.chomp
  response.to_i
end

def add_player(player_count)
  counter = 0
  while counter < player_count
    puts "What is your name?"
    name = gets.chomp
    new_player = Bettor.create(:name => name, :tokens => 20)
    $players_array << new_player
    counter += 1
  end
end


def find_team(team)
  team_data.body.find do |team_ob|
    team_ob["title"] == team
  end
end

def random_team
  team_data.body[rand(0..222)]
end

def match
  round_counter = 1
  player_team = {}

  while round_counter <= 5
    team_1 = random_team
    team_2 = random_team

    puts "\n\n\nThe following are the available games to bet on:\n\n\n"
    sleep(1)
    puts "#{team_1["title"]}\n\n"
    sleep(1)
    puts "vs."
    sleep(1)
    puts "\n\n#{team_2["title"]}"

    $players_array.each do |player|
      puts "#{player[:name]}: pick a team".colorize(:blue)
      team = gets.chomp
      player_team[player[:id]] = find_team(team)["id"]
    end

    player_team.each do |k, v|
      Bet.create(:bettor_id => k, :team_id => v)
    end

    array = [team_1["id"], team_2["id"]]
    winner = array.sample

    winners = get_winning_bets(winner)

    # $players_array.each do |player|
    #   if winners.include?(player)
    #     puts "#{player[:name]} won their bet and moves on!"
    #   else
    #     puts "#{player[:name]} lost their and loses 5 tokens!"
    #   end
    # end

    $players_array.each do |player|
      if outcomes(winners).include?(player[:id])
        puts "#{player[:name]} won their bet and moves on!"
      else
        puts "#{player[:name]} lost their bet and loses 5 tokens!"
        player.update(tokens:(player["tokens"]-5))
      end
    end

    total_score

    # binding pry
  #   if winner == tid && winner == tid2
  #     puts "BOTH PLAYERS WON THE ROUND!"
  #   elsif winner == tid && winner != tid2
  #     puts "Player 1 won the round!".colorize(:red)
  #     sleep(3)
  #     $p2_inst.update(tokens:($p2_inst["tokens"]-10))
  #     if $p2_inst["tokens"] <= 0
  #       puts "PLAYER ONE WON THE GAME!".colorize(:red)
  #       break
  #     end
  #   elsif winner == tid2 && winner != tid
  #     puts "Player 2 won the round!".colorize(:blue)
  #     sleep(3)
  #     $p1_inst.update(tokens:($p1_inst["tokens"]-10))
  #     if $p1_inst["tokens"] <= 0
  #       puts "PLAYER TWO WON THE GAME!".colorize(:blue)
  #       break
  #     end
  #   else
  #     winner != tid && winner != tid2
  #     puts "BOTH PLAYERS LOST THE ROUND!"
  #     $p1_inst.update(tokens:($p1_inst["tokens"]-10))
  #     $p2_inst.update(tokens:($p2_inst["tokens"]-10))
  #   end
  #   total_score
  binding.pry
  counter += 1

  puts "poo"
  end
end

def total_score
  counter = 0
  while counter < $players_array.size do
    puts "#{$players_array[counter][:name]} Total: #{$players_array[counter][:tokens]}"
    counter += 1
  end
end

def get_winning_bets(winner)
  Bet.all.select do |bet_obj|
    bet_obj[:team_id] == winner
  end
end

def outcomes(winners)
  winners.map do |winner_ob|
    winner_ob[:bettor_id]
  end
end
