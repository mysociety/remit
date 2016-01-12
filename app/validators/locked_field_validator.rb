class LockedFieldValidator < ActiveModel::Validator
  def initialize(options)
    super
    @locked_value = options[:locked_value]
    @attribute = options[:attribute]
  end

  def validate(record)
    attribute_was = record.send("#{@attribute}_was")
    return if attribute_was != @locked_value || record.new_record?

    attribute_changed = record.send("#{@attribute}_changed?")
    message = "You cannot change the name of the \"#{@locked_value}\" " \
      "#{record.class.name}, it's needed for other parts of the code to " \
      "work correctly."
    record.errors.add(@attribute, message) if attribute_changed
  end
end
