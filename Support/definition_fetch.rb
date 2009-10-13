#!/usr/bin/env ruby

class DefinitionFetch
  def initialize
    @ack = ENV['TM_ACK'] || ENV['TM_BUNDLE_SUPPORT'] + '/ack-standalone.sh'
    @mate = ENV['TM_MATE'] || '/usr/local/bin/mate'
    @dir = ENV['TM_PROJECT_DIRECTORY'] || '/Users/dbergey/repos/bitleap/branches/trunk'
  end
  
  # reveals the function in its file
  def goToDef(term)
    result = self.search(term)
    if result =~ /^(.*)\:([0-9]+)\:(.*)$/
      exec "#{@mate} --line #{$2} '#{@dir}/#{$1}'"
    else
      "Sorry, couldn't find a function, class or constant named '#{term}'."
    end
  end
  
  # fetches the function definition and shows it as a tooltip
  def getDef(term)
    result = self.search(term)
    if result =~ /^(.*)\:([0-9]+)\:(.*)$/
      $3 + "\n  " + $1 + ' (' + $2 + ')'
    else
      "Sorry, couldn't find a function, class or constant named '#{term}'."
    end
  end
  
  def search(term)
    # searching for ruby or php?
    if ( ENV['TM_SCOPE'] || [] ).split(" ").include?('source.ruby')
      search = ( term.upcase == term ) ? term + ' =' : 'class|def ' + term
    elsif ( ENV['TM_SCOPE'] || [] ).split(" ").include?('source.php')
      # NOTE: this is somewhat artificial as PHP does not strictly use uppercase-only constants
      search = ( term.upcase == term ) ? "define\\(\\W#{term}\\W" : 'function|class &?' + term
    else
      search = ''
    end
    
    search_command = "cd '#{@dir}'; '#{@ack}' -1 --after-context=0 --before-context=0 --nogroup --flush --nocolor --noenv --nofollow '#{search}'"
    
    result = ''
    IO.popen(search_command) do |pipe|
      pipe.each do |line|
        result << line
        $stdout.flush
      end
    end
    
    result
  end
end

# DEBUG
# ENV['TM_ACK'] = '/Users/dbergey/Library/Application Support/TextMate/Bundles/Daniel Bergey’s Bundle.tmbundle/Support/ack-standalone.sh'
# fetch = FunctionFetch.new
# puts fetch.getDef('cudatree_object_create_by_type')