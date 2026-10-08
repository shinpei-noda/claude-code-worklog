# frozen_string_literal: true

module Worklog
  # File locations used by the worklog. Everything lives under ~/.claude.
  class Config
    attr_reader :claude_dir

    def initialize(claude_dir: File.join(Dir.home, ".claude"))
      @claude_dir = claude_dir
    end

    def projects_dir
      File.join(claude_dir, "projects")
    end

    def worklog_dir
      File.join(claude_dir, "worklog")
    end

    def archive_path
      File.join(worklog_dir, "sessions.jsonl")
    end

    def calendar_path
      File.join(worklog_dir, "calendar.html")
    end

    def template_path
      File.expand_path("templates/calendar.html.erb", __dir__)
    end

    def transcript_paths
      # Only top-level files; subagent transcripts live in per-session subdirectories.
      # Unsorted to keep the filesystem order the Python version produced.
      Dir.glob(File.join(projects_dir, "*", "*.jsonl"), sort: false)
    end
  end
end
