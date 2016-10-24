require "str_enum/version"
require "active_support"

module StrEnum
  def str_enum(column, values, validate: true, scopes: true, accessor_methods: true, prefix: false)
    values = values.map(&:to_s)
    validates column, presence: true, inclusion: {in: values} if validate
    values.each do |value|
      prefix = column if prefix == true
      method_name = prefix ? "#{prefix}_#{value}" : value
      scope method_name, -> { where(column => value) } if scopes && !respond_to?(method_name)
      if accessor_methods && !method_defined?("#{method_name}?")
        define_method "#{method_name}?" do
          read_attribute(column) == value
        end
      end
    end
    after_initialize do
      send("#{column}=", values.first) unless send(column)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend(StrEnum)
end
