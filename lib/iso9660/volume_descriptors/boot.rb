class Iso
  module VolumeDescriptor
    BOOT_RECORD = 0x00
    class Boot
      include Virtus.model

      attribute :start_pos, Integer, :allow_nil => true
      attribute :end_pos, Integer, :allow_nil => true
      attribute :type, EndianInteger, :default => BOOT_RECORD
      attribute :boot_system_id, EndianString, :length => 32
      attribute :boot_id, EndianString, :length => 32
      attribute :system_use
      attribute :el_torito_address, LittleEndianInteger, :max => 4294967295
      def initialize(buf, start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos

        self.boot_system_id = buf[7, 32]
        self.boot_id = buf[39, 32]

        if self.boot_system_id == "EL TORITO SPECIFICATION"
        self.el_torito_address = buf[71, 4]
        self.system_use = buf[75, 1973]
        else
        self.system_use = buf[71, 1977]
        end
      end
    end
  end
end