require "hashie"

class Iso
  module VolumeDescriptor
    PRIMARY_VOLUME_DESCRIPTOR = 0x01
    class PrimaryVolumeDescriptor < Hashie::Dash
      property :start_pos
      property :end_pos
      property :type, default: PRIMARY_VOLUME_DESCRIPTOR
      property :system_id
      property :vol_id
      property :vol_space_size
      property :vol_set_size
      property :vol_seq_num
      property :block_size
      property :path_table_size
      property :path_table_l_loc
      property :path_table_opt_l_loc
      property :path_table_m_loc
      property :path_table_opt_m_loc
      property :vol_set_id
      property :publisher_id, default: 0x20
      property :data_preparer_id, default: 0x20
      property :application_id, default: 0x20
      property :copyright_file_id, default: 0x20
      property :abstract_file_id, default: 0x20
      property :bibliographic_file_id, default: 0x20
      property :vol_datetime_created
      property :vol_datetime_modified
      property :vol_datetime_expires
      property :vol_datetime_effective
      property :file_structure_version
      property :application_used
      def initialize(buff = "", start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.type = buff[0].unpack_char
        self.system_id = buff[8, 32].unpack_string
        self.vol_id = buff[40, 32].unpack_string
        self.vol_space_size = buff[80, 8].unpack_uint32
        self.vol_set_size = buff[120, 4].unpack_uint16
        self.vol_seq_num = buff[124, 4].unpack_uint16
        self.block_size = buff[128, 4].unpack_uint16
        self.path_table_size = buff[132, 8].unpack_uint32
        self.path_table_l_loc = buff[140, 4].unpack_uint32le
        self.path_table_opt_l_loc = buff[144, 4].unpack_uint32le
        self.path_table_m_loc = buff[148, 4].unpack_uint32be
        self.path_table_opt_m_loc = buff[152, 4].unpack_uint32be
        self.vol_set_id = buff[190, 128].unpack_string
        self.publisher_id = buff[318, 128].unpack_string
        self.data_preparer_id = buff[446, 128].unpack_string
        self.application_id = buff[574, 128].unpack_string
        self.copyright_file_id = buff[702, 38].unpack_string
        self.abstract_file_id = buff[740, 36].unpack_string
        self.bibliographic_file_id = buff[776, 37].unpack_string
        self.vol_datetime_created = buff[813, 17].unpack_string
        self.vol_datetime_modified = buff[830, 17].unpack_string
        self.vol_datetime_expires = buff[847, 17].unpack_string
        self.vol_datetime_effective = buff[864, 17].unpack_string
        self.file_structure_version = buff[881].unpack_char
        self.application_used = buff[883, 512].unpack_string
      end
    end
  end
end