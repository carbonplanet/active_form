ActiveForm::Validator::Base.create :proc do

  default_message '%s: validation failed'

  def initialize(*args, &block)
    @proc = block if block_given?
    super(*args)
  end

  def proc=(proc)
    @proc = proc
  end

  def validate
    @proc.call(self)
  end
  
  def advice
    Hash.new
  end

end