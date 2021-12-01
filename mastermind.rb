class Game

  def initialize
    @guesses = 0
    @user_play = false
    @computer_play = false
    @turn = 1
    @known_good_numbers = []
    @clue_one = 0
    @clue_two = 0
    @clue_add = true
    @one_time_do = true
    begin_game
  end

  def begin_game
    puts "Would you like to be the code cracker (enter 1) or code generator (enter 2)?"
    response = gets.chomp.to_f
    if response == 1
      @user_play = true
      begin_user_game
    elsif response == 2
      @computer_play = true
      begin_computer_game
    else
      puts "You need to enter 1 or 2"
      begin_game
    end
  end

  def begin_user_game
    puts "Mastermind
    
    You have 12 guesses to get the secret code, after each guess you will be given clues

    The code is 4 digits in length and each digit is between 1-6. Enter your first 4 digit code and hit enter"
    
    @code_attempt = get_user_input
    @code_to_crack = [rand(1..6), rand(1..6), rand(1..6), rand(1..6)]
    compare_codes(@code_to_crack, @code_attempt)
  end

  def begin_computer_game
    puts "Enter a 4 digit code where each digit is between 1-6 for your opponent to crack"

    @code_to_crack = get_user_input
    @code_attempt = get_computer_input
    compare_codes(@code_to_crack, @code_attempt)
  end

  def get_computer_input
    sleep(1)
    clues = @clue_one + @clue_two
    if clues > 0 && @clue_add == true
      clues.times {@known_good_numbers.push(@previous_attempt[1])}
    end
  
    if @turn == 1
      @turn += 1
      return [1,1,1,1]
    elsif @turn > 1 && @turn < 7 && @known_good_numbers.length < 4
      @turn += 1
      return [@previous_attempt[1] + 1,@previous_attempt[1] + 1,@previous_attempt[1] + 1,@previous_attempt[1] + 1]
    elsif @turn == 7 || @turn < 7 && @known_good_numbers.length == 4
      @turn = 8
      known_bad_number
      @clue_add = false
      stage_one
    else
      @clue_add = false
      stage_one
    end
  end


  def stage_one
    sleep(1)   
    if @turn == 8
      @turn += 1
      @num_one = @known_good_numbers[0]
      return [@num_one, @known_bad_number, @known_bad_number, @known_bad_number]
    elsif @clue_two == 0
      index_temp = @previous_attempt.index(@num_one)
      @previous_attempt[index_temp] = @known_bad_number
      @previous_attempt[index_temp + 1] = @num_one
      return @previous_attempt
    elsif @clue_two >0
      stage_two
    end 
  end

  def stage_two
  sleep(1)
    if @one_time_do == true
      @index_to_try = []
      @num_two = @known_good_numbers[1]
      @previous_attempt.each_with_index do |item, index|
        if item == @known_bad_number
          @index_to_try.push(index)
        end
      end
      @one_time_do = false
    end
    if @turn == 9
      @turn += 1
      @previous_attempt[@index_to_try[0]] = @num_two
      return @previous_attempt
    elsif @turn == 10 && @clue_two != 2
      @turn += 1
      @previous_attempt[@index_to_try[0]] = @known_bad_number
      @previous_attempt[@index_to_try[1]] = @num_two
      return @previous_attempt
    elsif @turn == 11 && @clue_two != 2
      @turn += 1
      @previous_attempt[@index_to_try[1]] = @known_bad_number
      @previous_attempt[@index_to_try[2]] = @num_two
      return @previous_attempt
    elsif @clue_two == 2
      if @previous_attempt.include?(@known_bad_number)
        @turn = 12
        stage_three
      else
        stage_three
      end
    end
  end

  def stage_three
    @num_three = @known_good_numbers[2]
    @num_four = @known_good_numbers[3]
    if @turn == 12
      @turn += 1
      @previous_attempt.each_with_index do |item, index| if item == @known_bad_number
          @previous_attempt[index] = @num_three
          break
        end
      end

      @previous_attempt.each_with_index do |item, index| if item == @known_bad_number
        @previous_attempt[index] = @num_four
        end
      end

      return @previous_attempt
    else      
      @num_three_index = @previous_attempt.index(@num_three)
      @num_four_index = @previous_attempt.index(@num_four)
      @previous_attempt[@num_three_index] = @num_four
      @previous_attempt[@num_four_index] = @num_three
      return @previous_attempt
    end
  end

  def known_bad_number
    num = 1
    6.times do if @known_good_numbers.include?(num)
      num += 1
    else
      @known_bad_number = num
      break
    end
    end
  end

  def get_user_input
    return input_check(gets.chomp.to_s.split('').map(&:to_i))
  end

  def compare_codes(code_to_crack, code_attempt)
    @clue_one = 0
    @clue_two = 0

     gen_code = code_to_crack.dup.map(&:dup)
     user_code = code_attempt.dup.map(&:dup)

    gen_code.each_with_index do |item, index|
      if item == user_code[index]
        @clue_two += 1
        user_code[index] = 7
        gen_code[index] = 8
      end
    end

    gen_code.each_with_index do |item, index|
      if user_code.include?(item)
        @clue_one += 1
        user_code[user_code.find_index(item)] = 7
      end
    end
  
    check_for_win
  end

  def check_for_win
    if @clue_two == 4
      if @user_play == true
        @guesses += 1
      puts "YOU CRACKED THE CODE! it took #{@guesses} guesses"
      elsif @computer_play == true
        @guesses += 1
        puts " #{@previous_attempt}
        
        Your code was cracked :( it held for #{@guesses} guess/s"
      end
    elsif @guesses == 11
      if @user_play == true
      puts "you ran out of goes, game over :(
        
      The code was #{@code_to_crack}"
      elsif @computer_play == true
        puts "#{@previous_attempt}
        
        Your code #{@code_to_crack} stood the challenge! good work"
      end

    else
      @guesses += 1
     next_turn
    end
  end

  def next_turn
    puts "  
      #{@code_attempt}  Correct number/s in the wrong position - #{@clue_one}
                    Correct number/s in the correct position - #{@clue_two}
                    
                    #{@guesses} guess/s. Try again"

      if @user_play == true
        @code_attempt = get_user_input
        compare_codes(@code_to_crack, @code_attempt)
      elsif @computer_play == true
        @previous_attempt = @code_attempt.dup.map(&:dup)
        @code_attempt = get_computer_input
        compare_codes(@code_to_crack, @code_attempt)
      end
    end
  end

  def input_check(input)
    if input.length == 4
      input.each do |item| if item < 1 || item >6 
        puts "You can only use 1-6 for each digit, try again"
        return input_check(gets.chomp.to_s.split('').map(&:to_i))
        end
      end
    else
      puts "The code needs to be exactly 4 digits long using 1-6 for each digit, try again"
      return input_check(gets.chomp.to_s.split('').map(&:to_i))
    end

end

Game.new
