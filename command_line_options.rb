require 'optparse'
require 'ostruct'

# Single responsibility: 
# parse options struct configurable by command-line
class SpanishCapybaraOptions
  attr_accessor :options
  
  def initialize
    @options = OpenStruct.new
    set_defaults
  end

  def get_options(argv)
    parse(ARGV)
    check_options
    options
  end

  private

  def set_defaults
    options.engine = :poltergeist
    options.scenario = :BarcelonaExtranjero
    options.capybara_default_wait_time = 20
    options.poltergeist_default_wait_time = 20 * 1000
    options.poltergeist_debug = false
    options.poltergeist_js_errors = false
    options.phantomjs_options = ['--debug=no', '--load-images=yes', '--ignore-ssl-errors=yes', '--ssl-protocol=any']
  end

  def check_engine
    supported_engines = [:selenium, :poltergeist]
    unless supported_engines.include? options.engine
      puts "Указанный драйвер #{options.engine} не поддерживается" 
      puts "Доступны следующие драйверы: #{supported_engines.to_s}" 
      exit(1)
    end
  end

  def check_scenario()
    supported_scenarios = [:BarcelonaRegresso, :BarcelonaExtranjero, :MadridExtranjero]
    unless supported_scenarios.include? options.scenario
      puts "Указанный сценарий #{options.scenario} не поддерживается" 
      puts "Доступны следующие сценарии: #{supported_scenarios.to_s}" 
      exit(1)
    end
  end

  def check_options
    check_engine
    check_scenario
  end

  def parse(argv)
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Вызов капибары: spanish_capybara.rb [options]"
      
      opts.on("-sMANDATORY", "Имя сценария для исполнения") do |scenario|
        options.scenario = scenario.to_sym
      end

      opts.on("-eMANDATORY", "selenium или poltergeist") do |engine|
        options.engine = engine.to_sym
      end

      opts.on("-cMANDATORY", "id клиента") do |id|
        options.client = id
      end
  
      opts.on_tail("-h", "--help", "Показать эту справку") do
        puts opts
        exit
      end    
    end
    opt_parser.parse!
  end
end