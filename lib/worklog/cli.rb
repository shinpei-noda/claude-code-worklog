# frozen_string_literal: true

module Worklog
  # Command-line entry point: worklog [sync|build|hook]
  class CLI
    USAGE = <<~TEXT
      Archive Claude Code session summaries and render them as a Schedule-X calendar.

      Usage:
        worklog sync     # scan all transcripts under ~/.claude/projects and update the archive
        worklog build    # render calendar.html from the archive
        worklog hook     # SessionEnd hook: read hook JSON from stdin, sync that transcript, build
    TEXT

    def initialize(config: Config.new, stdin: $stdin, stdout: $stdout)
      @config = config
      @stdin = stdin
      @stdout = stdout
    end

    def run(argv)
      case argv.fetch(0, "sync")
      when "sync"
        archive = sync(@config.transcript_paths)
        build(archive)
        @stdout.puts "#{archive.size} sessions -> #{@config.calendar_path}"
      when "build"
        build(Archive.load(@config.archive_path))
        @stdout.puts @config.calendar_path
      when "hook"
        path = PyCompat.parse_json(@stdin.read)["transcript_path"]
        build(sync(PyCompat.truthy?(path) && File.exist?(path) ? [path] : []))
      else
        abort USAGE
      end
    end

    private

    def sync(paths)
      archive = Archive.load(@config.archive_path)
      paths.each do |path|
        session = Transcript.new(path).summarize
        archive.store(session) if session
      end
      archive.save
      archive
    end

    def build(archive)
      html = Calendar.new(archive, template_path: @config.template_path).render
      AtomicFile.write(@config.calendar_path, html)
    end
  end
end
