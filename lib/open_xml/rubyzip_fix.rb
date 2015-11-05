require "zip"

module Zip
  class InputStream
  protected

    # The problem in RubyZip 1.1.0 is that we only call `seek`
    # when `io` is a File. We need to move the cursor to the
    # right position when `io` is a StringIO as well.
    def get_io(io, offset = 0)
      io = ::File.open(io, "rb") unless io.is_a?(IO) || io.is_a?(StringIO)
      io.seek(offset, ::IO::SEEK_SET)
      io
    end

  end
end
