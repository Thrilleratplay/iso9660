class Iso
  module VolumeDescriptor
    PRIMARY_VOLUME_DESCRIPTOR = 0x01
    class PrimaryVolumeDescriptor
      include Virtus.model

      attribute :start_pos, Integer, :allow_nil => true
      attribute :end_pos, Integer, :allow_nil => true
      attribute :type, EndianInteger, :default => PRIMARY_VOLUME_DESCRIPTOR
      attribute :system_id, EndianString, :length => 32
      attribute :vol_id, EndianString, :length => 32
      attribute :vol_space_size, EndianInteger, :max => 65535
      attribute :vol_set_size, EndianInteger, :max => 255
      attribute :vol_seq_num, EndianInteger, :max => 255
      attribute :block_size, EndianInteger, :max => 255
      attribute :path_table_size, EndianInteger, :max => 65535
      attribute :path_table_l_loc, LittleEndianInteger, :max => 4294967295
      attribute :path_table_opt_l_loc, LittleEndianInteger, :max => 4294967295
      attribute :path_table_m_loc, BigEndianInteger, :max => 4294967295
      attribute :path_table_opt_m_loc, BigEndianInteger, :max => 4294967295
      attribute :vol_set_id, EndianString, :length => 128
      attribute :publisher_id, EndianString, :length => 128
      attribute :data_preparer_id, EndianString, :length => 128
      attribute :application_id, EndianString, :length => 128
      attribute :copyright_file_id, EndianString, :length => 38
      attribute :abstract_file_id, EndianString, :length => 36
      attribute :bibliographic_file_id, EndianString, :length => 37
      attribute :vol_datetime_created
      attribute :vol_datetime_modified
      attribute :vol_datetime_expires
      attribute :vol_datetime_effective
      attribute :application_used
      def initialize(buf, start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.system_id = buf[8, 32]
        self.vol_id = buf[40, 32]
        self.vol_space_size = buf[80, 8]
        self.vol_set_size = buf[120, 4]
        self.vol_seq_num = buf[124, 4]
        self.block_size = buf[128, 4]
        self.path_table_size = buf[132, 8]
        self.path_table_l_loc = buf[140, 4]
        self.path_table_opt_l_loc = buf[144, 4]
        self.path_table_m_loc = buf[148, 4]
        self.path_table_opt_m_loc = buf[152, 4]
        self.vol_set_id = buf[190, 128]
        self.publisher_id = buf[318, 128]
        self.data_preparer_id = buf[446, 128]
        self.application_id = buf[574, 128]
        self.copyright_file_id = buf[702, 38]
        self.abstract_file_id = buf[740, 36]
        self.bibliographic_file_id = buf[776, 37]
        self.vol_datetime_created = buf[813, 17]
        self.vol_datetime_modified = buf[830, 17]
        self.vol_datetime_expires = buf[847, 17]
        self.vol_datetime_effective = buf[864, 17]
        self.application_used = buf[883, 512]
      end
    end
  end
end