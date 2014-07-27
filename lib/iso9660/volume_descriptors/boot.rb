require "iso9660/byte_order_helpers"

class Iso
  include ByteOrderHelpers  
  
  module VolumeDescriptor
    BOOT_RECORD = 0x00
    class Boot
      attr_writer :start_pos
      attr_writer :end_pos
      attr_writer :type
      attr_writer :boot_system_identifier
      attr_writer :boot_identifier
      attr_writer :boot_system_use
      attr_writer :el_torito_address
      def start_pos
        @start_pos ||= nil
      end

      def end_pos
        @end_pos ||= nil
      end

      def type
        @type ||= BOOT_RECORD
      end

      def boot_system_identifier
        @boot_system_identifier ||= ""
      end

      def boot_identifier
        @boot_identifier ||= ""
      end

      def boot_system_use
        @boot_system_use ||= ""
      end

      def el_torito_address
        @el_torito_address ||= ""
      end

      def initialize(buffer = "", start_pos = nil, end_pos = nil)
        @start_pos = start_pos
        @end_pos = end_pos
        @type = buffer[0].unpack_unsigned_char
        @boot_system_identifier = buffer[7, 32].unpack_binary_string
        @boot_identifier = buffer[39, 32].unpack_binary_string

        if @boot_system_identifier == "EL TORITO SPECIFICATION"
          @el_torito_address = buffer[71, 4].unpack_little_uint32
          @boot_system_use = buffer[75, 1973]
        else
          @boot_system_use = buffer[71, 1977]
        end
      end
    end
  end
end