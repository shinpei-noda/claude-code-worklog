# frozen_string_literal: true

module Worklog
  # A Claude Code transcript file (~/.claude/projects/<project>/<session_id>.jsonl).
  class Transcript
    PROMPT_PREVIEW_LENGTH = 300
    TITLE_FALLBACK_LENGTH = 60

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def session_id
      PyCompat.splitext_root(PyCompat.basename(path))
    end

    # Build a session summary. Returns nil if the transcript has no prompts.
    def summarize
      scan
      return nil unless @timeline.any_prompt?

      Session.new(
        "session_id" => session_id,
        "cwd" => @cwd,
        "project" => @cwd ? PyCompat.basename(@cwd) : PyCompat.basename(PyCompat.dirname(path)),
        "branches" => @branches,
        "title" => @title || PyCompat.first_line(@first_prompt || "(untitled)")[0, TITLE_FALLBACK_LENGTH],
        "first_prompt" => @first_prompt,
        "segments" => @timeline.segments.map(&:to_h),
      )
    end

    private

    def scan
      @title = nil
      @cwd = nil
      @branches = []
      @first_prompt = nil
      @timeline = Timeline.new

      File.foreach(path, encoding: "UTF-8") do |line|
        entry = Entry.parse(line)
        record(entry) if entry
      end
    end

    def record(entry)
      @title = entry.ai_title if entry.ai_title
      return if entry.sidechain?

      @cwd = entry.cwd if entry.cwd
      @branches << entry.git_branch if entry.git_branch && !@branches.include?(entry.git_branch)
      return unless entry.activity?

      record_first_prompt(entry.prompt_text)
      @timeline.add(entry.time, prompt: entry.prompt?)
    end

    # Prefer a typed prompt over slash commands such as /clear or /model.
    def record_first_prompt(text)
      return unless PyCompat.truthy?(text)
      return unless @first_prompt.nil? || (@first_prompt.start_with?("/") && !text.start_with?("/"))

      @first_prompt = text[0, PROMPT_PREVIEW_LENGTH]
    end
  end
end
