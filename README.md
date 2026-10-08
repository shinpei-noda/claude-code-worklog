# worklog

Render Claude Code session history as a [Schedule-X](https://github.com/schedule-x/schedule-x) calendar.

## Usage

```sh
ruby ~/.claude/worklog/exe/worklog sync   # scan all transcripts and rebuild the calendar
ruby ~/.claude/worklog/exe/worklog build  # rebuild the calendar from sessions.jsonl only
open ~/.claude/worklog/output/calendar.html
```

`worklog hook` is meant for the Claude Code `SessionEnd` hook. It reads the hook JSON from stdin and adds that session only.

## Files

Generated files go to `output/`, which is not tracked by Git.

- `output/sessions.jsonl`: session summaries; outlives the transcripts Claude Code cleans up
- `output/calendar.html`: generated calendar page
- `lib/worklog/templates/calendar.html.erb`: calendar page template

## Layout

| Class | Responsibility |
|---|---|
| `Worklog::CLI` | Command dispatch (`sync`, `build`, `hook`) |
| `Worklog::Config` | File locations under `~/.claude` |
| `Worklog::Transcript` | Summarizes one transcript file into a `Session` |
| `Worklog::Entry` | One transcript line; extracts the user-typed prompt |
| `Worklog::Timeline` | Splits activity into segments at idle gaps |
| `Worklog::Session` | One record of `sessions.jsonl` |
| `Worklog::Archive` | Loads, merges, and saves `sessions.jsonl` |
| `Worklog::Calendar` | Renders sessions with the ERB template |
| `Worklog::AtomicFile` | Writes files via a temporary file and rename |
| `Worklog::PyCompat` | Python semantics kept for output compatibility with the former Python version |
