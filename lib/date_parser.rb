
module DateParser

  MONTHS = {
    'jan' => '01',
    'feb' => '02',
    'mar' => '03',
    'apr' => '04',
    'may' => '05',
    'jun' => '06',
    'jul' => '07',
    'aug' => '08',
    'sep' => '09',
    'oct' => '10',
    'nov' => '11',
    'dec' => '12',
    'january' => '01',
    'february' => '02',
    'march' => '03',
    'april' => '04',
    'june' => '06',
    'july' => '07',
    'august' => '08',
    'september' => '09',
    'october' => '10',
    'november' => '11',
    'december' => '12'
  }

  def self.searchable(verbatim)
    return verbatim unless verbatim

    unless verbatim.match(/\d\d/)  #at least most of a year
      return verbatim
    end

    if verbatim.match(/(\S+)\s(\S+)\s(\S+)/)
      d = $1
      vm = $2
      vy = $3
    elsif verbatim.match(/\s?(\S+)\s(\S+)/)
      d = '*'
      vm = $1
      vy = $2
    elsif verbatim.match(/(\d\d\d\d)/)
      d = '*'
      vm = '*'
      vy = $1
    elsif verbatim.match(/(\d\d\d_)/)
      d = '*'
      vm = '*'
      vy = $1
    elsif verbatim.match(/(\d\d__)/)
      d = '*'
      vm = '*'
      vy = $1
    else
      return verbatim
    end

    # handle unclear years
    if vy.match(/(\d\d\d)[_*]/)
      vy = $1 + '5'
    end

    if vy.match(/(\d\d)__/) || vy.match(/(\d\d)\*/)
      vy = $1 + '50'
    end

    if vy.match(/(\d\d\d\d)?/)
      vy = $1.gsub(/\?/, '')
    end

    # handle split years
    if vy.match(/(\d+)\//)
      y = $1.to_i + 1
    else
      y = vy
    end

    # convert month names to numbers
    if MONTHS[vm.downcase]
      m = MONTHS[vm.downcase]
    else
      m = vm
    end

    # zero-pad
    if d.match(/\b\d\b/)
      d = "0" + d
    end

    "#{y}-#{m}-#{d}"
  end

  def self.start_search_date(year)
    # zero-pad for completionist users inputting three-digit years
    year.to_s.rjust(4, '0')
  end

  def self.end_search_date(year)
    # make the year inclusive
    next_year = year + 1
    next_year = next_year.to_s.rjust(4, '0')
    # calculate new year
    if next_year.to_i < 1753
      next_year = "#{next_year}-03-25"
    else
      next_year = "#{next_year}-01-01"
    end
    next_year
  end

end
