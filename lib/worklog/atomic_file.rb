# frozen_string_literal: true

require "fileutils"
require "tempfile"

module Worklog
  # Writes a file via a temporary file and rename, so readers never see a partial file.
  module AtomicFile
    module_function

    def write(path, text)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      file = Tempfile.create("tmp", dir)
      file.write(text)
      file.close
      File.chmod(0o600, file.path)
      File.rename(file.path, path)
    end
  end
end
