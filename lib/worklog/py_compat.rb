# frozen_string_literal: true

require "json"
require "time"

module Worklog
  # Helpers that reproduce Python semantics where Ruby differs, so the output
  # (sessions.jsonl, calendar.html) stays byte-compatible with the former Python version.
  module PyCompat
    # Characters Python's str.isspace() treats as whitespace.
    WHITESPACE = Regexp.escape(
      [*0x09..0x0d, *0x1c..0x20, 0x85, 0xa0, 0x1680, *0x2000..0x200a, 0x2028, 0x2029, 0x202f, 0x205f, 0x3000].pack("U*"),
    )
    STRIP_PATTERN = /\A[#{WHITESPACE}]+|[#{WHITESPACE}]+\z/
    # Line boundaries recognized by Python's str.splitlines().
    LINE_BREAK = Regexp.union("\r\n", /[#{Regexp.escape([*0x0a..0x0d, 0x1c, 0x1d, 0x1e, 0x85, 0x2028, 0x2029].pack("U*"))}]/)
    JSON_ESCAPES = { '"' => '\\"', "\\" => "\\\\", "\n" => '\\n', "\r" => '\\r', "\t" => '\\t', "\b" => '\\b', "\f" => '\\f' }.freeze

    module_function

    # Python truthiness: None, False, 0 and empty str/list/dict are falsy.
    def truthy?(value)
      !(value.nil? || value == false || value == 0 || ((value.is_a?(String) || value.is_a?(Array) || value.is_a?(Hash)) && value.empty?))
    end

    def strip(text)
      text.gsub(STRIP_PATTERN, "")
    end

    def first_line(text)
      text.split(LINE_BREAK, 2)[0]
    end

    def basename(path)
      path[(path.rindex("/") || -1) + 1..]
    end

    def dirname(path)
      head = path[0, (path.rindex("/") || -1) + 1]
      head.match?(%r{\A/*\z}) ? head : head.sub(%r{/+\z}, "")
    end

    # os.path.splitext(path)[0]
    def splitext_root(path)
      sep_index = path.rindex("/") || -1
      dot_index = path.rindex(".") || -1
      return path unless dot_index > sep_index

      path[sep_index + 1...dot_index].match?(/[^.]/) ? path[0...dot_index] : path
    end

    def parse_json(text)
      JSON.parse(text, allow_nan: true)
    end

    # json.dumps(value, ensure_ascii=False)
    def dump_json(value)
      case value
      when Hash then "{#{value.map { |k, v| "#{dump_json(k.to_s)}: #{dump_json(v)}" }.join(', ')}}"
      when Array then "[#{value.map { |v| dump_json(v) }.join(', ')}]"
      when String then %("#{value.gsub(/["\\\u0000-\u001f]/) { |c| JSON_ESCAPES[c] || format('\\u%04x', c.ord) }}")
      when nil then "null"
      else value.to_s
      end
    end

    # datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone()
    def parse_time(value)
      time = Time.iso8601(value.gsub("Z", "+00:00")).localtime
      # Python datetime keeps microseconds only.
      Time.at(time.to_i, time.usec, :usec).localtime
    end

    # datetime.isoformat() for an aware datetime.
    def isoformat(time)
      fraction = time.usec.zero? ? "" : format(".%06d", time.usec)
      time.strftime("%Y-%m-%dT%H:%M:%S#{fraction}%:z")
    end
  end
end
