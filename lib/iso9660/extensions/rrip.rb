require "hashie"

# Rock Ridge Interchange Protocol
module RRIP
  RRIP_TAGS = {
    "RR" => "Rock Ridge extensions in-use indicator (DEPRECATED)",
    "PX" => "POSIX file attributes",
    "PN" => "POSIX device numbers",
    "SL" => "symbolic link",
    "NM" => "alternate name",
    "CL" => "child link",
    "PL" => "parent link",
    "RE" => "relocated directory",
    "TF" => "time stamp",
    "SF" => "sparse file data"
  }

  RRIP_FILE_FLAGS = {
    "0" => "Continue",
    "1" => "Current",
    "2" => "Parent",
    "3" => "Root"
  }

  RRIP_TIME_FLAGS = {
    "\x01" => "Creation",
    "\x02" => "Modify",
    "\x04" => "Access",
    "\x08" => "Attributes",
    "\x10" => "Backup",
    "\x20" => "Expiration",
    "\x40" => "Effective",
    "\x100" => "LongForm"
  }

  class PXclass < Hashie::Dash
    property :file_mode
    property :file_links
    property :user_id
    property :group_id
    property :file_serial_number
    def initialize(buf)
      self.file_mode = buf[4, 8]
      self.file_links = buf[12, 8].unpack_uint32
      self.user_id = buf[20, 8].unpack_uint32
      self.group_id = buf[28, 8].unpack_uint32
      self.file_serial_number = buf[36, 8]
    end
  end

  class PNclass < Hashie::Dash
    property :dev_high
    property :dev_low
    def initialize(buff)
      self.dev_high = buf[4, 8].unpack_uint32
      self.dev_low =  buf[12, 8].unpack_uint32
    end
  end

  class SLclass < Hashie::Dash
    property :flags
    property :component_area
    def initialize(buf)
      self.flags = buf[4]
      self.component_area = buf[5..-1].unpack_string
    end
  end

  class NMclass < Hashie::Dash
    property :flags
    property :name_content
    def initialize(buf)
      self.flags = buf[4]
      self.name_content = buf[5..-1].unpack_string
    end
  end

  class CLclass < Hashie::Dash
    property :location_of_child_dir
    def initialize(buf)
      self.location_of_child_dir = buf.unpack_string
    end
  end

  class PLclass < Hashie::Dash
    property :location_of_parent_dir
    def initialize(buf)
      self.location_of_parent_dir = buf.unpack_string
    end
  end

  class REclass < Hashie::Dash
    property :sigiture_word, default: "RE"
  end

  class TFclass < Hashie::Dash
    property :flags
    property :timestamps
    def initialize(buf)
      self.flags = buf[5]
      self.timestamps = buf[6..-1].unpack_string
    end
  end

  class SFclass < Hashie::Dash
    property :size_high
    property :size_low
    property :table_depth
    def initialize(buf)
      self.size_high =  buf[4, 8].unpack_uint32
      self.size_low =  buf[12, 8].unpack_uint32
      self.table_depth = buf[20]
    end
  end

  class RockRidge
    attr_accessor(:RR, :PX, :PN, :SL, :NM, :CL, :PL, :RE, :TF, :SF)

    def initialize(system_use)
      while system_use.length > 1
       tag, length, version = system_use.unpack("A2CC")

       case tag
       when "PX"
         @PX = PXclass.new(system_use[0, length])
       when "PN"
         @PN = PNclass.new(system_use[0, length])
       when "SL"
         @SL = SLclass.new(system_use[0, length])
       when "NM"
         @NM = NMclass.new(system_use[0, length])
       when "CL"
         @CL = CLclass.new(system_use[0, length])
       when "PL"
         @PL = PLclass.new(system_use[0, length])
       when "RE"
         @RE = REclass.new(system_use[0, length])
       when "TF"
         @TF = TFclass.new(system_use[0, length])
       when "SF"
         @SF = SFclass.new(system_use[0, length])
       else
         puts tag
       end
       #length-=1
       system_use = system_use[length..-1]
      end
    end
  end
end