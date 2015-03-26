require "techbook_helper/version"
require 'fileutils'

gem 'colorize'
require 'colorize'

trap "SIGINT" do
  puts " "
  puts "Exiting"
  exit 130
end

module TechbookHelper
  class Helper

    IMAGES_DIR = '_i'
    INDEX_MD   = 'index.md'
    GIT_KEEP   = '.keep'

    def say_hello

      @help_args = ['-h', 'h', '--h', '-help', 'help', '--help']
      @create_args = ['create', '-create', '--create', 'c', '-c', '--c']
      @check_args = ['check', '-check', '--check', 'ch', '-ch', '--ch']

      @confirm_args = ['y', 'yes', 'ok', 'sure']
      @reject_args = ['n', 'no', 'o no', 'do not', 'exit', 'close']

      @current_book_name = nil

      print_help if ARGV.size == 0
      if ARGV.size > 1
        too_many_arg_error
        return
      end

      ARGV.each do |a|
        handler_arguments a
      end

    end

    def handler_arguments(arg)
      case
        when @help_args.include?(arg)
          puts "Welcome to TechBook helper!".colorize(:color => :white, :background => :black)
          puts 'type cd path_to_your_book_repository and lets go.'
          puts_line
          print_help
        when @create_args.include?(arg)
          create
        else
          print_unknown_command(arg)
      end
    end

    def create

      if is_dir_used?
        puts "We find other files in this directory:".red
        puts "'#{Dir['*'].join("', '")}'".blue
        puts "One book – one folder."
        puts "Are you want #{'delete all'.red} and create new empty book?"
        puts "(yes/no)?"
        unless yes_no_choice
          puts_ok
          return
        end
        clear_current_dir
      end

      unless check_git_dir
        puts 'Looks like git not initialized in current directory'.yellow
      end

      current_dir = Dir.pwd
      puts 'Ok, lest do it.'
      puts "Confirm you wana create TechBook template in directory #{current_dir.green}"
      print '(yes/no) '

      if yes_no_choice
        select_book_name
      else
        puts_ok
      end

    end

    def clear_current_dir
      puts 'Clear files in current directory'.red

      Dir['*'].each do |file|
        if File.directory? file
          FileUtils.rm_rf file
        else
          File.delete file
        end
      end

      10.times{print '. '; sleep 0.3;}
      puts ' '
      puts 'Done'
      sleep(0.4)
      puts_line
    end

    def select_book_name
      puts "One more question. What the name of your book?"
      print_promt
      while user_input = STDIN.gets.chomp
        case
          when user_input.nil? || user_input.size == 0
            puts "I am not sure this is good idea to create book with empty name"
            puts "Please, try again"
            print_promt
          else
            puts "Build template for book name \"#{user_input}\""
            build_template user_input

            puts 'Are you want to create top level chapters? (y/n)'
            if yes_no_choice
              create_root_chapters
            else
              puts_ok
            end

            break
        end
      end
    end

    def build_chapter(name)
      if @current_book_name.nil?
        puts "Do not know which book to work with".red
        return
      end

      Dir.mkdir(File.join(@current_book_name, name))
      puts "Create chapter  \"#{name}\""
      sleep(0.4)
      File.open(File.join(@current_book_name, name, INDEX_MD), 'w').close
      puts 'Index page'
      sleep(0.5)

    end

    def build_template(name)
      Dir.mkdir(name)
      puts 'Create root directory'
      sleep(0.4)
      File.open(File.join(name, INDEX_MD), 'w').close
      puts 'Index page'
      sleep(0.4)
      Dir.mkdir(File.join(name, IMAGES_DIR))
      sleep(0.4)
      puts 'Create images directory'
      puts_line
      puts 'Book template complete. You can edit it, commit and push to the server... manually for now ;)'
      puts_line
      sleep(0.5)

      @current_book_name = name
    end

    def create_root_chapters
      puts 'Top level chapters creation'
      puts_line
      puts 'For exit type "exit"'
      puts 'Enter chapter name (ex: "1 Specification", "2 Money and low")'
      print_promt
      while user_input = STDIN.gets.chomp
        case
          when user_input.nil? || user_input.size == 0
            puts "Chapter with empty name? Are you kidding me?"
            puts "Please, give me something more intelligent"
            print_promt
          when @reject_args.include?(user_input)
            puts_ok
            break
          else
            build_chapter user_input
            puts 'For exit type "exit"'
            puts 'Enter chapter name'
            print_promt
        end
      end
    end


    def check_git_dir
      Dir.exist?('.git')
    end

    def is_dir_used?
      files_array = Dir['*']
      return true unless files_array.empty?
      return false
    end

    def print_help
      puts 'Command you can use:'
      puts '%-10s – %10s' % ['create'.green, 'Will create new book template in current directory']
      puts '%-10s – %10s' % [' ', 'Aliases c, -c, --c, -create, --create']
      puts '%-10s – %10s' % ['check'.green, 'Go through dirs in current folder and check known problems']
      puts '%-10s – %10s' % [' ', 'Aliases ch, -ch, --ch, -check, --check']
      puts_line
    end

    def print_unknown_command(command)
      puts "Unknown command: #{command}"
      puts_line
      print_help
    end

    def too_many_arg_error
      puts 'Too many arguments.'.red.on_black
      puts_line
      print_help
    end

    def yes_no_choice
      print_promt
      answer = false
      while user_input = STDIN.gets.chomp
        case
          when @confirm_args.include?(user_input)
            answer = true
            break
          when @reject_args.include?(user_input)
            answer = false
            break
          else
            puts "Please, answer the question – yes or no"
            print_promt
        end
      end
      answer
    end

    def print_promt
      print ':> '.green
    end

    def puts_line
      puts '--------------------------'
    end

    def puts_ok
      puts 'I respect your choice'
    end

  end
end
