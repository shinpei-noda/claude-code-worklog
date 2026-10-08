# frozen_string_literal: true

module Worklog
  # sessions.jsonl: session summaries that outlive the transcripts Claude Code cleans up.
  class Archive
    include Enumerable

    def self.load(path)
      archive = new(path)
      return archive unless File.exist?(path)

      File.foreach(path, encoding: "UTF-8") do |line|
        archive.store(Session.parse(line)) unless PyCompat.strip(line).empty?
      end
      archive
    end

    def initialize(path)
      @path = path
      @sessions = {}
    end

    # Adds or replaces a session. A replaced session keeps its original position.
    def store(session)
      @sessions[session.id] = session
    end

    def each(&)
      @sessions.each_value(&)
    end

    def size
      @sessions.size
    end

    def save
      sorted = @sessions.values.sort_by.with_index { |session, i| [session.started_at, i] }
      AtomicFile.write(@path, sorted.map(&:to_json_line).join)
    end
  end
end
