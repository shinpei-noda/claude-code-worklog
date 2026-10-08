# frozen_string_literal: true

# Archive Claude Code session summaries and render them as a Schedule-X calendar.
module Worklog
end

require_relative "worklog/version"
require_relative "worklog/py_compat"
require_relative "worklog/atomic_file"
require_relative "worklog/config"
require_relative "worklog/entry"
require_relative "worklog/timeline"
require_relative "worklog/session"
require_relative "worklog/transcript"
require_relative "worklog/archive"
require_relative "worklog/calendar"
require_relative "worklog/cli"
