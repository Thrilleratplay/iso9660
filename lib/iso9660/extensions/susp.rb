require "hashie"

# System Use Sharing Protocol
module SUSP
  SUSP_TAGS = {
    "CE" => "Continuation area",
    "PD" => "Padding field",
    "SP" => "System use sharing protocol indicator",
    "ST" => "System use sharing protocol terminator",
    "ER" => "Extensions reference",
    "ES" => "Extension selector"
  }

  class CEclass < Hashie::Dash
    property :location
    property :offset
    property :len
    def initialize(buf)
      self.location =buf[4, 8].unpack_uint32
      self.offset = buf[12, 8].unpack_uint32
      self.len = buf[20, 8].unpack_uint32
    end
  end

  class PDclass < Hashie::Dash
    property :padding_area
    def initialize(buf)
      self.padding_area = buf[4..-1].unpack_string
    end
  end

  class SPclass < Hashie::Dash
    property :bytes_skipped
    def initialize(buf)
      self.padding_area = buf[6..-1].unpack_uint32
    end
  end

  #class STclass < Hashie::Dash
  #  property :
   # def initialize(buf)
   # end
  #end

  class ERclass < Hashie::Dash
    property :extension_version
    property :identifier
    property :descriptor
    property :source
    def initialize(buf)
      self.extension_version = buf[7].unpack_uint32

      len = buf[4].unpack_char + 8
      self.identifier = buf[8, len].unpack_string

      start_buf = len
      len += buf[5].unpack_char
      self.descriptor = buf[start_buf, len].unpack_string

      offset += buf[6].unpack_char
      self.source = buf[start_buf, len].unpack_string
    end
  end
end