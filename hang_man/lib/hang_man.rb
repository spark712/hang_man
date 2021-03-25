require 'yaml'

class Hangman
  attr_accessor :chances, :i, :j, :misses, :correct, :secret_word, :show
  def initialize
    @chances = 6
    @i = 0
    @j = 0
    @misses = []
    @correct = []
    @secret_word = ''
    @show = []
  end

  def result(shw, scrt_wrd, i)
    puts `clear`
    if shw == scrt_wrd
      puts "    \"#{shw.join}\""
      puts "Congratulations You Won!!"
      @i = 6
    elsif shw != scrt_wrd && i == 6
      puts "You Lost! Better Luck next time."
      puts "The correct word was: '#{scrt_wrd.join}'"
    end   
  end

  def save_game
    puts `clear`
    puts "Enter the name of the file to be saved: "
    save_name = gets.chomp
    Dir.mkdir('saved_games') unless Dir.exists?('saved_games')
    
    File.open("./saved_games/#{save_name}.yml", 'w') do |f|
      YAML.dump([] << self, f)
    end
    puts 'File saved'
    exit
  end

  def rounds
    puts `clear`
    puts @show.join
    puts "Guess count: #{@j}"
    puts "Misses: #{@misses}"
    puts "Correct guesses: #{@correct.uniq}"
    puts "Chances left: #{6 - @i}"
    print "Enter any character (from a-z) or type 'save' to save the game: "
    @choice = gets.chomp
    puts @choice

    if @choice == 'save'
      self.save_game
    elsif @show.include?(@choice) || !/^[a-z]$/.match?(@choice)
      puts 'This character has already been entered or is INVALID. Please enter another character: '
      sleep(1.5)
    elsif @secret_word.include?(@choice)
      @secret_word.each_with_index do |chr, idx|
        if chr == @choice 
          @show[idx] = @choice
          @correct << @choice
        end
      end
      @j += 1
    else
      @misses << @choice
      @i += 1
      @j += 1
    end
    self.result(@show, @secret_word, @i) if (@show.join == @secret_word.join || @i == 6)  
  end

  def secrets
    @valid_words = []
    
    words = File.open('5dest.txt', 'r').each do |line|
      word = line.downcase.slice(0..-3)
      @valid_words << word if word.length >= 5 && word.length <= 12
    end
    return @valid_words
  end

  def load_game
    puts `clear`
    puts "Loading.."
    sleep(1)
    unless Dir.exists?('saved_games')
      puts "No saved games available. Sending back to main menu.."
      sleep(2)
      return
    end
    games = saved_games
    puts games
    deserailize(load_file(games))
  end

  def load_file(games)
    loop do
      puts 'Enter which saved game would you like to load: '
      load_file_name = gets.chomp
      return load_file_name if games.include?(load_file_name)

      puts 'The game you requested does not exist.'
      sleep(1.5)
      self.main_menu 
    end
  end

  def deserailize(load_file_name)
    yaml = YAML.load_file("./saved_games/#{load_file_name}.yml")
    
    @chances = yaml[0].chances
    @i = yaml[0].i
    @j = yaml[0].j
    @misses = yaml[0].misses
    @correct = yaml[0].correct
    @secret_word = yaml[0].secret_word
    @show = yaml[0].show
    
    self.new_game
  end

  def saved_games
    puts 'Saved games: '
    Dir['./saved_games/*'].map { |file| file.split('/')[-1].split('.')[0] }
  end

  def new_game
    puts `clear`
    puts ""
    
    while @i < 6
      self.rounds
    end
  end

  def main_menu
    puts `clear`
    puts "        Main menu"
    puts "     1. New Game"
    puts "     2. Load Game"
    puts "     3. Exit"
    option = gets.chomp
    case option
    when '1'
      @secret_word = self.secrets.sample.split('')
      @show = Array.new(@secret_word.length, '-')
      self.new_game
    when '2'
      self.load_game
    when '3'
      exit
    else
      puts `clear`
      self.main_menu
    end
  end

end
puts "--:Welcome to Hangman:--"
sleep(2)
game = Hangman.new
game.main_menu