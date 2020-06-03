module Services
  class Percent
    def initialize(new, original)
      @new = new
      @original = original
    end

    def self.diff(new, original)
      Percent.new(new, original)
    end

    def value
      (((@new.to_f - @original.to_f) / @original.to_f) * 100).round(2)
    end

    def to_s
      value.to_s + '%'
    end
  end
end
