require 'ostruct'

module ErbCompile
  def erb_compile(obj)
    case
    when obj.kind_of?(Hash)
      new_obj = Hash.new
      JSON.parse(obj.to_json).each do |k,v|
        new_obj[erb_compile(k)] = erb_compile(v)
      end
      new_obj
    when obj.kind_of?(Array)
      new_obj = Array.new
      JSON.parse(obj.to_json).each {|v| new_obj.push(erb_compile(v)) }
      new_obj
    when obj.kind_of?(String)
      values = ::OpenStruct.new({:node => self.node})
      if obj =~ /^<%=(.+?)%>$/
        eval( obj.sub(/^<%=\s*/, "").sub(/\s*%>$/, ""), values.instance_eval{ binding })
      else
        new_obj = ::ERB.new(obj).result(values.instance_eval{ binding })
        new_obj = JSON.parse(new_obj) rescue new_obj
        new_obj
      end
    else
      obj
    end
  end

  def json_pretty(atr)
    JSON.pretty_generate(erb_compile(atr))
  end

  def yaml_pretty(atr)
    erb_compile(atr).to_yaml
  end
  alias_method :yml_pretty, :yaml_pretty

end

[ Chef::Recipe, Chef::Mixin::Template::TemplateContext, Chef::Resource::File ].each do |klass|
  klass.send(:include, ErbCompile) unless klass.respond_to?('erb_compile')
end
