class SanatisedParams < Struct.new(:params, :for_user)

  METHODS_AVAILABLE = EditableParams.instance_methods(false)

  def method_missing(method, *args, &block)
    if METHODS_AVAILABLE.include?(method)
      params[method].permit(*editable_params.send(method))
    else
      super
    end
  end

  def respond_to?(method)
    METHODS_AVAILABLE.include?(method) ? true : super
  end


  private
  def editable_params
    @editable_params ||= EditableParams.new(for_user)
  end

end
