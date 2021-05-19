## 基本

```ruby
class UnionFind
  def initialize(size); @p, @r = [*0...size], [1] * size; end
  def leader(i); j = i; until i == @p[i]; j, i = i, @p[j] = @p[i]; end; i; end
  def merge(i, j); k, l = leader(i), leader(j); return false if k == l; k, l = l, k if @r[k] < @r[l]; @p[l] = k; @r[k] += @r[l]; true; end
  def same?(i, j); leader(i) == leader(j); end
  def size(i); @r[leader(i)]; end
end
```

## 連結成分を保持する

- `merge(i, j)`: O(N log N)

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

- `merge(i, j) { |x, y| ... }`: O(N log N)
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
