require "iso9660/byte_order_helpers"

class Iso
  include ByteOrderHelpers

  module VolumeDescriptor
    TERMINATOR = 0x255
    class Terminator
      attr_writer :start_pos
      attr_writer :end_pos
      attr_writer :type
      def start_pos
        @start_pos ||= nil
      end

      def end_pos
        @end_pos ||= nil
      end

      def type
        @type ||= TERMINATOR
      end

      def initialize(buffer = "", start_pos = nil, end_pos = nil)
        @start_pos = start_pos
        @end_pos = end_pos
        @type = buffer[0].unpack_unsigned_char
      end
    end
  end
end  