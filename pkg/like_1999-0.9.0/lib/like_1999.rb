# encoding: utf-8
$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Date
  def like(s)
    self.to_time.like(s)
  end
end

def Time.set_default_template_language(lang)
  @lang = lang
end

def Time.default_template_language
  @lang
end

class Time
  CONVERSION = { "99" => "%y", "1999" => "%Y", "12" => "%m", "366" => "%j", "31" => "%d", 
                 "23" => "%H", "11" => "%I", "pm" => "%p", "59" => "%M", "00" => "%S", "utc" => "%Z"
  }

# {"th" => :en, "ju" => :es, "do" => [:de, :nl], "je" => :fr, "to" => :se, "gi" => :it, }
# {"su" => :en, "do" => [:es,:it], "zo" => :nl, "so" => :de, "di" => :fr, "sö" => :se }
# {"may" => [:en,:es], "mei" => :nl, "mai" => [:de,:fr], "maj" => :se, "mag" => :it, }

  LANG_DATA = {
    :en => { 
           :conversion => {"su" => :sday, "sun" => :day, "sunday" => :lday, "dec" => :month, "december" => :lmonth },
           :sday => %w(su mo tu we th fr sa),
           :day => %w(sun mon tue wed thu fri sat),
           :lday => %w(sunday monday tuesday wednesday thursday friday saturday),
           :month => %w(X jan feb mar apr may jun jul aug sep oct nov dec),
           :lmonth => %w(X january february march april may june july august september october november december)},
    :es => { 
           :conversion => {"sun" => :day, "sunday" => :lday, "dec" => :month, "december" => :lmonth },
           :day => %w(lu ma mi ju vi sa do),
           :lday => %w(),
           :month => %w(X ene feb mar abr may jun jul ago sep oct nov dic),
           :lmonth => %w(X )},
    :it => { 
           :conversion => {"sun" => :day, "sunday" => :lday, "dec" => :month, "december" => :lmonth },
           :sday => %w(lu ma me gi ve sa do),
           :day => %w(lun mar mer gio ven sab dom),
           :lday => %w(),
           :month => %w(X gen feb mar apr mag giu lug ago set ott nov dic),
           :lmonth => %w(X )},
    :se => { 
           :conversion => {"sun" => :day, "sunday" => :lday, "dec" => :month, "december" => :lmonth },
           :sday => %w(må ti on to fr lö sö),
           :day => %w(mån tis ons tor fre lör sön),
           :lday => %w(),
           :month => %w(X jan febr mars april maj juni juli aug sept okt nov dec),
           :lmonth => %w(X )},
    :nl => { 
           :conversion => {"zo" => :day, "zondag" => :lday, "dec" => :month, "december" => :lmonth },
           :day => %w(zo ma di wo do vr za),
           :lday => %w(zondag maandag dinsdag woensdag donderdag vrijdag zaterdag),
           :month => %w(X jan feb mrt apr mei jun jul aug sep okt nov dec),
           :lmonth => %w(X januari februari maart april mei juni juli augustus september oktober november december)},
    :de => { 
           :conversion => {"so" => :day, "sonntag" => :lday, "dez" => :month, "dezember" => :lmonth },
           :day => %w(so mo di mi do fr sa),
           :lday => %w(sonntag montag dienstag mittwoch donnerstag freitag samstag),
           :month => %w(X jan feb mär apr mai jun jul aug sep okt nov dez),
           :lmonth => %w(X januar februar märz april mai juni juli august september oktober november dezember)},
    :fr => { 
           :conversion => {"di" => :day, "dimanche" => :lday, "déc" => :month, "décembre" => :lmonth },
           :day => %w(di lu ma me je ve sa),
           :lday => %w(dimanche lundi mardi mercredi jeudi vendredi samedi),
           :month => %w(x janv févr mars avril mai juin juil août sept oct nov déc),
           :lmonth => %w(X janvier février mars avril mai juin juillet août septembre octobre novembre décembre)},
  }

  # +s+ Uses a natural format to specify a date/time format, by using a reference date/time.
  # This time is Sunday, December 31 1999, 23:59 UTC, or Sun 12-31-99 11:59 PM.
  # See README for details.
  # +lang+ A two-letter string or symbol. (e.g. "en")
  def like(s, lang = nil)
    l = lang || Time.default_template_language || :en
    lang_data = LANG_DATA[l.to_sym]
    raise "Language #{lang} not supported." unless lang_data
    match_capitalization = lambda {|t,z| z == z.downcase ? t.downcase : z == z.upcase ? t.upcase : t.capitalize }
    t = s.split(/([A-Z]+)|(\d+)/i).map do |x|
      if y = lang_data[:conversion][x.downcase]
        unit = (y == :day || y == :lday) ? wday : month
        match_capitalization[lang_data[y][unit], x]
      else 
        CONVERSION[x.downcase] || x
      end
    end
    strftime t.join
  end
end
