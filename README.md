# worklog

Render Claude Code session history as a [Schedule-X](https://github.com/schedule-x/schedule-x) calendar.

## Usage

```sh
ruby ~/.claude/worklog/exe/worklog sync   # scan all transcripts and rebuild the calendar
ruby ~/.claude/worklog/exe/worklog build  # rebuild the calendar from sessions.jsonl only
open ~/.claude/worklog/output/calendar.html
```

## Hook setup

`worklog hook` reads the `SessionEnd` hook JSON from stdin, adds that session to `sessions.jsonl`, and rebuilds the calendar. Add it to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "ruby ~/.claude/worklog/exe/worklog hook"
          }
        ]
      }
    ]
  }
}
```

The hook runs in the session's project directory with the PATH Claude Code was started with, so `ruby` resolves through that PATH and the project's `.ruby-version`. Ruby 3.3 or later is required. If that is not guaranteed, use an absolute path such as `~/.rbenv/versions/3.4.7/bin/ruby`.

Claude Code deletes transcripts after 30 days by default. `sessions.jsonl` keeps the summaries regardless, but you can also keep the transcripts longer:

```json
{
  "cleanupPeriodDays": 365
}
```
