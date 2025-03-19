module BigDecimalCompat
  def new(*args)
    BigDecimal(*args)
  end
end

if !BigDecimal.respond_to?(:new)
  BigDecimal.singleton_class.prepend(BigDecimalCompat)
end

