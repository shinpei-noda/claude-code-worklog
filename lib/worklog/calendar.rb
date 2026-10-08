# frozen_string_literal: true

require "erb"

module Worklog
  # Renders sessions as a Schedule-X calendar page.
  class Calendar
    # Short segments are stretched to this length (seconds) so they stay visible in the calendar.
    MIN_EVENT_LENGTH = 15 * 60

    def initialize(sessions, template_path:)
      @sessions = sessions.to_a
      @template_path = template_path
    end

    def render
      ERB.new(File.read(@template_path, encoding: "UTF-8")).result_with_hash(payload: payload)
    end

    private

    def payload
      data = {
        "generatedAt" => Time.now.strftime("%Y-%m-%d %H:%M"),
        "projects" => projects.map { |p| { "name" => p, "calendarId" => calendar_ids[p] } },
        "events" => events,
      }
      # Escape "<" so prompt text cannot close the surrounding <script> element.
      PyCompat.dump_json(data).gsub("<", "\\u003c")
    end

    def projects
      @projects ||= @sessions.map(&:project).uniq.sort
    end

    def calendar_ids
      @calendar_ids ||= projects.each_with_index.to_h { |project, i| [project, "p#{i}"] }
    end

    def events
      @sessions.flat_map do |session|
        session.segments.each_with_index.map { |segment, index| event(session, segment, index) }
      end
    end

    def event(session, segment, index)
      start = PyCompat.parse_time(segment["start"])
      finish = [PyCompat.parse_time(segment["end"]), start + MIN_EVENT_LENGTH].max
      {
        "id" => "#{session.id}-#{index}",
        "title" => session.title,
        "start" => format_time(start),
        "end" => format_time(finish),
        "calendarId" => calendar_ids[session.project],
        "sessionId" => session.id,
        "project" => session.project,
        "cwd" => session.cwd,
        "branches" => session.branches,
        "prompts" => segment["prompts"],
        "firstPrompt" => session.first_prompt,
      }
    end

    def format_time(time)
      time.strftime("%Y-%m-%d %H:%M")
    end
  end
end
