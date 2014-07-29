require "hashie"

class Iso
  module VolumeDescriptor
    BOOT_RECORD = 0x00
    class Boot < Hashie::Dash
      property :start_pos
      property :end_pos
      property :type, default: BOOT_RECORD
      property :boot_system_identifier
      property :boot_identifier
      property :boot_system_use
      property :el_torito_address
      def initialize(buff = "", start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.type = buff[0].unpack_char
        self.boot_system_identifier = buff[7, 32].unpack_string
        self.boot_identifier = buff[39, 32].unpack_string

        if self.boot_system_identifier == "EL TORITO SPECIFICATION"
        self.el_torito_address = buff[71, 4].unpack_uint32le
        self.boot_system_use = buff[75, 1973]
        else
        self.boot_system_use = buff[71, 1977]
        end
      end
    end
  end
end