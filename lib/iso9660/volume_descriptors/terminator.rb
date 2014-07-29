require "hashie"

class Iso
  module VolumeDescriptor
    TERMINATOR = 0x255
    class Terminator < Hashie::Dash
      property :start_pos
      property :end_pos
      property :type, default: TERMINATOR
      def initialize(buff = "", start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.type = buff[0].unpack_char
      end
    end
  end
end  