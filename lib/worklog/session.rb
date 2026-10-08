# frozen_string_literal: true

module Worklog
  # A session summary as stored in sessions.jsonl.
  #
  # Wraps the record hash as-is so records loaded from the archive are written back unchanged.
  class Session
    def self.parse(line)
      new(PyCompat.parse_json(line))
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def id
      @attributes["session_id"]
    end

    def cwd
      @attributes["cwd"]
    end

    def project
      @attributes["project"]
    end

    def branches
      @attributes.fetch("branches", [])
    end

    def title
      @attributes["title"]
    end

    def first_prompt
      @attributes["first_prompt"]
    end

    def segments
      @attributes["segments"]
    end

    def started_at
      segments[0]["start"]
    end

    def to_json_line
      "#{PyCompat.dump_json(@attributes)}\n"
    end
  end
end
