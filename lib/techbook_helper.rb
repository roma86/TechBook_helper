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
      # @check_args = ['check', '-check', '--check', 'ch', '-ch', '--ch']

      @confirm_args = ['y', 'yes', 'ok', 'sure', 'Yes', 'No']
      @reject_args = ['n', 'no', 'o no', 'do not', 'exit', 'close', 'cancel', 'next']

      @current_book_name = nil
      @current_book_directory = nil

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
          puts "Welcome to TechBook helper!".green
          puts 'cd path_to_your_books_library_or_book and lets go.'
          puts_line
          print_help
        when @create_args.include?(arg)
          create
        else
          print_unknown_command(arg)
      end
    end

    def create

      puts 'Ok, lest do it.'
      puts 'Helper will create new book in current directory:'
      puts "  #{Dir.pwd}  ".blue.on_white
      puts_line
      puts 'What the name of new book?:'
      print_promt

      while user_input = STDIN.gets.chomp
        case
          when user_input.nil? || user_input.size == 0
            puts 'Hmmm... Book without name at all? Are you kidding me?'
            puts "Please, give me something more intelligent"
            puts "If you want to cancel, just say 'cancel' or 'exit'"
            print_promt
          when @reject_args.include?(user_input)
            puts_ok
            break
          else
            check_book_exist user_input
            break
        end
      end

    end

    def check_book_exist(book_name)
      current_folder_name = File.basename(Dir.pwd)
      @current_book_name = book_name
      @current_book_directory = File.join(Dir.pwd, book_name)

      if current_folder_name == book_name
        puts 'Attention! Attention please!'.yellow
        puts 'Helper now inside directory with book name you are typed'
        puts 'Dow you want to clear existing files and create book inside current directory?'.red

        if yes_no_choice
          @current_book_directory = Dir.pwd
          clear_book_dir
        end
      end

      if Dir.exist?(book_name)
        puts 'Book with same name already exist in current place'.red
        puts 'Want to empty it and create new book?'
        if yes_no_choice
          clear_book_dir
        end
      end

      build_template

      puts 'Want to create top level chapters?'
      if yes_no_choice
        create_root_chapters
      end

      init_repository

    end

    def clear_book_dir
      puts "Clear book #{@current_book_name}".red

      Dir["#{@current_book_directory}/*"].each do |file|
        if File.directory? file
          FileUtils.rm_rf file
        else
          File.delete file
        end
      end

      Dir["#{@current_book_directory}/.*"].each do |file|
        unless File.basename(file) == '.' || File.basename(file) == '..'
          if File.directory? file
            FileUtils.rm_rf file
          else
            File.delete file
          end
        end
      end

      10.times{print '. '; sleep 0.3;}
      puts 'Done'
      sleep(0.4)
      puts_line
    end

    def build_chapter(name)
      if @current_book_directory.nil?
        puts "Do not know which book to work with".red
        return
      end

      Dir.mkdir(File.join(@current_book_directory, name))
      puts "Create chapter  \"#{name}\""
      sleep(0.4)
      File.open(File.join(@current_book_directory, name, INDEX_MD), 'w').close
      puts 'Index page'
      sleep(0.5)

    end

    def build_template
      unless Dir.exist?(@current_book_directory)
        Dir.mkdir(@current_book_directory)
        puts 'Create root directory'
        sleep(0.4)
      end
      File.open(File.join(@current_book_directory, INDEX_MD), 'w').close
      puts 'Create Index page'
      sleep(0.4)
      Dir.mkdir(File.join(@current_book_directory, IMAGES_DIR))
      File.open(File.join(@current_book_directory, IMAGES_DIR, GIT_KEEP), 'w').close
      sleep(0.4)
      puts 'Create images directory'
      puts_line
      puts 'Book template complete'
      puts_line
      sleep(0.5)
    end

    def create_root_chapters
      puts 'Top level chapters creation'
      puts_line
      puts_for_next
      puts 'Enter chapter name (ex: "1 Specification", "2 Money and low")'
      print_promt
      while user_input = STDIN.gets.chomp
        case
          when user_input.nil? || user_input.size == 0
            puts "Chapter with empty name? Are you kidding me?"
            puts "Please, give me something more intelligent"
            print_promt
          when @reject_args.include?(user_input)
            puts 'Build chapters complete'
            puts_line
            break
          else
            build_chapter user_input
            puts_for_next
            puts 'Enter chapter name'
            print_promt
        end
      end
    end

    def init_repository
      puts 'Create git repository'
      Dir.chdir(@current_book_directory) do
        `git init`
        `git add .`
        `git commit -m "Build book #{@current_book_name} template"`
      end
      10.times{print '. '; sleep 0.1;}
      puts 'Done'
      sleep(0.2)
      puts_line

      add_git_remote
    end

    def add_git_remote
      puts 'Want to add remote url to this book?'
      if yes_no_choice
        puts_for_next
        puts 'Type git remote url:' #https://
        print_promt
        while user_input = STDIN.gets.chomp
          case
            when user_input.nil? || user_input.size == 0
              puts_for_next
              puts 'Do not play with me!'
              puts 'Enter valid url or go to exit!'
              print_promt
            when @reject_args.include?(user_input)
              puts_ok
              break
            when !user_input.start_with?('https://')
              puts_for_next
              puts 'Sorry. We need url start from https://'
              puts 'Please, try again'
              print_promt
            else
              Dir.chdir(@current_book_directory) do
                `git remote add origin #{user_input}`
              end
              puts 'Remote url added to git'.green
              break
          end
        end
      end
      print_finish_message
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
      # puts '%-10s – %10s' % ['check'.green, 'Go through dirs in current folder and check known problems']
      # puts '%-10s – %10s' % [' ', 'Aliases ch, -ch, --ch, -check, --check']
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
      print '(Yes/No) '.green
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
            puts 'Please, answer the question – yes or no'
            print_promt
        end
      end
      answer
    end

    def print_finish_message
      puts 'We are finish.'
      puts "Book '#{@current_book_name}' was created!"
      puts_line
      puts 'Add and edit .md pages, commit and push to remote to publish this book'
      puts 'Thanks'
      1.times{puts ''}
    end

    def print_promt
      print ':> '.green
    end

    def puts_for_next
      puts 'For exit and continue type "next"'.yellow
    end

    def puts_line
      puts '--------------------------'
    end

    def puts_ok
      puts 'I respect your choice'
    end

  end
end

# what to check
# files without md in directories
# directories without index.md
# where is _i directory
# root index file