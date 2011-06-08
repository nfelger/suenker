require 'rubygems'
require 'fsevents'
require 'fileutils'
require 'term/ansicolor'

include Term::ANSIColor

STDOUT.sync = true


options = {
 :directory_to_watch => "/Users/nfelger/dev/songkick",
 :remote_host        => 'of1-dev-nfelger',
 :remote_dir         => "dev/songkick",
 :verbose            => ARGV.any?{|arg| ['-v', '--verbose'].include?(arg)}
}


def sync(options)
  print "\033[14D", red, bold, "sünking...    ", reset
  start = Time.now
  verbosity = options[:verbose] ? 'v' : 'q'
  cmd = "rsync -#{verbosity}arx --delete -e ssh --filter='. #{options[:directory_to_watch]}/rsync.filter' #{options[:directory_to_watch]}/ #{options[:remote_host]}:#{options[:remote_dir]}/"
  system(cmd)
  $0 = "Last sünked #{Time.now.strftime("%X")}"
  print "\033[14D"; print green, bold, "ready ", reset, "(#{(Time.now - start).to_i.to_s.rjust(5, " ")}s)", reset
end

print "              "

sync(options)

excluded_dirs = [".redcar", ".git", ".idea"]

FileUtils.cd(options[:directory_to_watch]) do
 stream = FSEvents::Stream.watch(options[:directory_to_watch], :latency => 1.0) do |events|
   events.modified_files.detect do |path|
     unless excluded_dirs.any?{ |dir| path.include?(dir) }
       sync(options)
       true
     end
   end
 end
 stream.run
end
