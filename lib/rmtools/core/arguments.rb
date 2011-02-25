# encoding: utf-8
class Array
  
  # a, b, opts = [<hash1>].fetch_opts([<hash2>, <object1>]) may work unintuitive:
  # you'll get <hash1> as `a' and not as `opts'
  # So if function is not implying that some argument other than `opts' definetly 
  # must be a hash, don't make hash default. 
  # Better put hashie argument into opts like
  # b, opts = [<hash1>].fetch([<object1>], :a => <hash2>)
  # and get `a' from `'opts' hash
  def fetch_opts(defaults=[], opts={})
    if Hash === defaults
      opts = defaults
      defaults = []
      $log.warn "fetch_opts(<hash>) now changed"
    end
    opts &&= if self[-1].kind_of?(Hash) and !defaults[size-1].kind_of?(Hash)
      opts.merge pop
    else
      opts.dup
    end
    if defaults == :flags
      defauls = [:flags]
    end
    if defaults.last == :flags
      defaults.pop
      flags = defaults.size..-1
      if defaults.size < size
        self[flags].each {|flag| opts[flag] = true}
        self[flags] = []
      end
    end
    each_index {|i| import(defaults, i) if self[i] == :def}
    defaults.slice! 0, size
    concat defaults << opts
  end
  alias :fetch_options :fetch_opts
  alias :get_opts :fetch_opts

  def valid_types(pattern_ary)
    each_with_index.find {|var, i|
      pattern = pattern_ary[i]
      if pattern.is Array
             pattern.find {|j| !(pattern[j] === var[i])}
      else !(pattern === var[i])
      end
    }
  end
  
end

