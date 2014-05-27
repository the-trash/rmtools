# encoding: utf-8
require 'rmtools/core/object'

class Class
  
  def method_proxy *vars
    buffered_missing = instance_methods.grep(/method_missing/).sort.last || 'method_missing'
    # next arg overrides previous
    vars.each {|v|
      class_eval "
      alias #{buffered_missing.bump! '_'} method_missing
      def method_missing *args, &block
        #{v}.send *args, &block
      rescue NoMethodError
        #{buffered_missing} *args, &block
      end"
    }
  end
  
  def personal_methods filter=//
    (self.singleton_methods - self.superclass.singleton_methods).sort!.grep(filter)
  end
  
  def my_instance_methods filter=//
    (self.public_instance_methods - Object.public_instance_methods).sort!.grep(filter)
  end
  
  def personal_instance_methods filter=//
    (self.public_instance_methods - self.superclass.public_instance_methods).sort!.grep(filter)
  end
  
  # differs with #ancestors in that it doesn't show included modules
  def superclasses
    superclass ? superclass.unfold(lambda {|c|!c}) {|c| [c.superclass, c]} : []
  end
  
  private
  # define python-style initializer
  # p = Post()
  # p = Post user_id: 10
  def __init__
    path = name.split('::')
    classname = path[-1]
    mod = '::'.in(name) ? eval(path[0..-2]*'::') : RMTools
    if mod.is Module
      mod.module_eval "def #{classname} *args, &block; #{name}.new *args, &block end
                   module_function :#{classname}"
      if mod != RMTools
        mod.each_child {|c| c.class_eval "include #{mod}; extend #{mod}" if !c.in c.children}
      end
    else
      mod.class_eval "def #{classname} *args, &block; #{name}.new *args, &block end"
    end
  end 
  
  def alias_constant(name)
    class_eval %{
    def #{name}(key=nil)
      key ? self.class::#{name}[key] : self.class::#{name}
    end}
  end
  
end

require 'set'
[Hash, Set, Regexp, File, Dir, Range, Class, Module, Thread, Proc].each {|klass| klass.class_eval {__init__}}