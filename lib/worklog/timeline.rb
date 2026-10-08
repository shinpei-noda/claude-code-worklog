# frozen_string_literal: true

module Worklog
  # Groups activity timestamps into segments separated by idle gaps.
  class Timeline
    # Activity gaps longer than this (seconds) split a session into separate calendar events.
    SEGMENT_GAP = 30 * 60

    Segment = Struct.new(:start, :end, :prompts) do
      def to_h
        { "start" => PyCompat.isoformat(start), "end" => PyCompat.isoformat(self.end), "prompts" => prompts }
      end
    end

    def initialize
      @activity = [] # [time, prompt?]
    end

    def add(time, prompt:)
      @activity << [time, prompt]
    end

    def any_prompt?
      @activity.any? { |_, prompt| prompt }
    end

    def segments
      # Stable sort: equal timestamps keep their transcript order.
      @activity.sort_by.with_index { |(time, _), i| [time, i] }.each_with_object([]) do |(time, prompt), segments|
        if !segments.empty? && time.to_r - segments.last.end.to_r <= SEGMENT_GAP
          segments.last.end = time
        else
          segments << Segment.new(time, time, 0)
        end
        segments.last.prompts += 1 if prompt
      end
    end
  end
end
