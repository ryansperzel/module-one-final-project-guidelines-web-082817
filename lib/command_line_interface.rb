require 'unirest'
require 'colorize'
require 'colorized_string'
require 'catpix'

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
  puts "Welcome to the World Cup!".bold

  fifa_logo
  pid = fork{ exec 'afplay', "audio/cheer.mp3" }
  # pid = fork{ exec 'killall', "afhplay" }
  # 'afplay audio/cheer.mp3`
end

def player_count
  puts "How many players are playing?"
  response = gets.chomp
  until response.to_i != 0
    puts "Invalid response, please pick a number."
    response = gets.chomp
  end
  response.to_i
end

def add_player(player_count)
  counter = 0
  while counter < player_count
    puts "\n\nWhat is your name?"
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


def colors
  color_codes.keys
end

def match

  round_counter = 1
  player_team = {}

  until $players_array.length <= 1 || round_counter == 10
    team_1 = random_team
    team_2 = random_team

    puts "\n\n\nThe following are the available games to bet on:\n\n\n"
    sleep(1)
    pid = fork{ exec 'afplay', "audio/whistle.wav" }
    puts "#{team_1["title"].bold}\n\n"
    sleep(1)
    puts "vs."
    sleep(1)
    puts "\n\n#{team_2["title"].bold}"

    $players_array.each do |player|
      puts "\n\n\n#{player[:name].bold}: pick a team".colorize(:blue)
      team = gets.chomp
      until team == team_1["title"] || team == team_2["title"]
        puts "That team isn't playing! Please pick a team from above\n\n"
        team = gets.chomp
      end
      player_team[player[:id]] = find_team(team)["id"]
    end

    player_team.each do |k, v|
      Bet.create(:bettor_id => k, :team_id => v)
    end

    array = [team_1["id"], team_2["id"]]
    winner = array.sample

    winners = get_winning_bets(winner)

    # [fifa_logo(team_1), red_card(team_2)].sample

    $players_array.each do |player|
      if outcomes(winners).include?(player[:id])
        sleep(1)
        puts "\n\n\n#{player[:name].blue.bold} won their bet and moves on!"
      else
        sleep(1)
        puts "\n\n\n#{player[:name].blue.bold} lost their bet and loses 5 tokens!"
        player.update(tokens:(player["tokens"]-20))
        if player[:tokens] <= 0
          sleep(1)
          puts "\n\n\n#{player[:name].blue.bold} has no more tokens and has been eliminated from the game!"
        end
      end
    end

    $players_array.delete_if do |player|
      player[:tokens] <= 0
    end

    puts "\n\n\n_________________________________________________________________________\nCURRENT TOTALS:\n\n".bold

    total_score

    puts "\n\n\n_________________________________________________________________________\n\n\n"

  round_counter += 1

  end
end


def game_winner
  if $players_array.length == 1
    sleep(3)
    puts "\n\n\n*****************************\nCongrats #{$players_array.first[:name].blue.bold} you won the game!\n*****************************\n\n\n".yellow.blink
    trophy
    puts "\n\n\n*****************************\nCongrats #{$players_array.first[:name].blue.bold} you won the game!\n*****************************\n\n\n".yellow.blink
  elsif $players_array.length == 0
    sleep(3)
    puts "\n\n\nYOU ALL LOSE!".red.blink
  elsif $players_array.length > 1
    current_high
  end
end

def total_score
  sleep(1)
  counter = 0
  while counter < $players_array.size do
    puts "\n\n\n#{$players_array[counter][:name].blue.bold} Total: #{$players_array[counter][:tokens]}"
    counter += 1
  end
end


def current_high
  sorted_tokens = $players_array.sort_by do |player|
    player[:token]
  end

  token_high = sorted_tokens.first[:token]
  winner_names = []
  $players_array.each do |player|
    if player[:token] == token_high
      winner_names << player[:name]
    end
  end
  puts "GAME OVER\n\n\n"
  sleep(3)
  puts "CALCULATING WINNERS\n\n\n"
  sleep(1)
  "\n\n."
  sleep(1)
  "\n\n."
  sleep(1)
  "\n\n."
  sleep(2)
  puts "#{winner_names.join(' & ')} tied!".green.blink
  trophy
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

def fifa_logo
  # puts "#{team_1['title']} scores a penalty kick!"
  Catpix::print_image "lib/fifa.jpg",
    :limit_x => 0.75,
    :limit_y => 0.75,
    :center_x => false,
    :center_y => false,
    :bg => "white",
    :bg_fill => false,
    :resolution => "high"
end

def trophy
  Catpix::print_image "lib/trophy.png",
    :limit_x => 0.5,
    :limit_y => 0.5,
    :center_x => false,
    :center_y => false,
    :bg => "white",
    :bg_fill => false,
    :resolution => "low"
end

# def red_card(team_2)
#   puts "#{team_2['title']} gets a red card and they are down a man!"
#   Catpix::print_image "lib/red_card.png",
#     :limit_x => 0.75,
#     :limit_y => 0.75,
#     :center_x => false,
#     :center_y => false,
#     :bg => "white",
#     :bg_fill => false,
#     :resolution => "low"
# end
#
#
#
# def events(team_1, team_2)
#   [fifa_logo(team_1), red_card(team_2)].sample
#   # event_array[0]
# end
