require 'date/format'

module ParseDate

  def self.parsedate(datestring)
    Date._parse(datestring, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)
  end

end
