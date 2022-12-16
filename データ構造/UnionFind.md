## 基本

```ruby
class UnionFind
  def initialize(size); @p = Array.new(size, -1); end
  def leader(i); j = i; j, i = i, @p[j] = @p[i] until @p[i] < 0; i; end
  def merge(i, j); k, l = leader(i), leader(j); return false if k == l; k, l = l, k if @p[k] > @p[l]; @p[k] += @p[l]; @p[l] = k; true; end
  def same?(i, j); leader(i) == leader(j); end
  def size(i); -@p[leader(i)]; end
  def groups; g = {}; @p.size.times { |i| (g[leader(i)] ||= []) << i }; g.values; end
end
```

## 連結成分を保持する

- `merge(i, j)`: O(log N) amortized

```ruby
uf = UnionFind.new(3)
uf.merge(1, 2)
p uf.component(1) #=> [1, 2]
```

```ruby
class UnionFind
  def initialize(size); @p = [*0...size]; @r = @p.map { |i| [i] }; end
  def leader(i); j = i; until i == @p[i]; j, i = i, @p[j] = @p[i]; end; i; end
  def merge(i, j); k, l = leader(i), leader(j); return false if k == l; k, l = l, k if @r[k].size < @r[l].size; @p[l] = k; @r[k].push *@r[l]; true; end
  def same?(i, j); leader(i) == leader(j); end
  def size(i); @r[leader(i)].size; end
  def component(i); @r[leader(i)]; end
end
```

## 可換半群が載る

- `merge(i, j) { |x, y| ... }`: O(log N) amortized
  - `x` に `y` を合成するとマージテクができる

```ruby
uf = UnionFind.new([1, 2, 3])
uf.merge(1, 2) { |x, y| x + y }
p uf[1] #=> 5
```

```ruby
class UnionFind
  def initialize(size, init = nil); if size.is_a? Integer; @x = [init] * size; else; @x = size; size = @x.size; end; @p, @r = [*0...size], [1] * size; end
  def leader(i); j = i; until i == @p[i]; j, i = i, @p[j] = @p[i]; end; i; end
  def merge(i, j, &f); k, l = leader(i), leader(j); return false if k == l; k, l = l, k if @r[k] < @r[l]; @p[l] = k; @r[k] += @r[l]; @x[k] = f[@x[k], @x[l]]; true; end
  def same?(i, j); leader(i) == leader(j); end
  def size(i); @r[leader(i)]; end
  def [](i); @x[leader(i)]; end
end
```


## Undo できる

未Verify

```ruby
class UndoableUnionFind
  def initialize(size); @p, @r, @h = [*0...size], [1] * size, []; end
  def leader(i); j = i; until i == @p[i]; j, i = i, @p[j] = @p[i]; end; i; end
  def merge(i, j); k, l = leader(i), leader(j); return false if k == l; @h << [k, l, @r[k], @r[l]]; k, l = l, k if @r[k] < @r[l]; @p[l] = k; @r[k] += @r[l]; true; end
  def undo; return if @h.empty?; k, l, s, t = @h.pop; @p[k], @p[l], @r[k], @r[l] = k, l, s, t; end
  def same?(i, j); leader(i) == leader(j); end
  def size(i); @r[leader(i)]; end
end
```

## ポテンシャル付き

ポテンシャルは可換群である必要がある。

```ruby
class PotentializedUnionFind
 	# Verify: https://onlinejudge.u-aizu.ac.jp/solutions/problem/DSL_1_B/review/6018983/magurofly/Ruby
     attr_reader :potential
 
     # 初期化
     def initialize(n)
         @components = Array.new(n) { |i| [i] }
         @potential = Array.new(n, 0)
     end
     
     # 連結成分を取得
     def [](i)
         @components[i]
     end
 
     # ポテンシャルの差を取得
     def diff(i, j)
         x, y = @components[i], @components[j]
         return nil if x != y
         @potential[j] - @potential[i]
     end
     
     # ポテンシャルを指定して連結
     # @potential[i] + d = @potential[j]
     def merge(i, j, d)
         x, y = @components[i], @components[j]
         if x == y
             raise "potential contradiction" if @potential[i] + d != @potential[j]
             return false
         end
         if x.size >= y.size
             diff = @potential[i] - @potential[j] + d
             y.each do |k|
                 @components[k] = x
                 x << k
                 @potential[k] += diff
             end
         else
             diff = @potential[j] - @potential[i] - d
             x.reverse_each do |k|
                 @components[k] = y
                 # y.unshift k
                 y << k
                 @potential[k] += diff
             end
         end
         true
     end
 end
 ```
