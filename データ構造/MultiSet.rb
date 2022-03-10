class MultiSet
  attr_reader :size, :kind
  def initialize(iter = nil)
    @hash, @size, @kind = Hash.new(0), 0, 0
    iter.each { |x| self.add x } if iter
  end
  def include?(x) @hash[x] > 0 end
  def add(x)
    c = @hash[x]
    @hash[x] += 1
    @size += 1
    @kind += 1 if c == 0
    true
  end
  def <<(x)
    add(x)
    self
  end
  def remove(x)
    c = @hash[x]
    return false if c == 0
    @hash[x] -= 1
    @size -= 1
    @kind -= 1 if c == 1
    true
  end
  def count(x) @hash[x] end
end
