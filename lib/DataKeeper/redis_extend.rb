module RedisExtend
  # 没取到值返回nil
  def get(key)
    key_valid? key
    redis_instance.get(key)
  end

  # 删除不存在的key也不会报错
  def del(key)
    key_valid? key
    redis_instance.del(key)
  end

  #一旦到期立刻归-2，最小值为1
  def ttl(key)
    key_valid? key
    redis_instance.ttl(key)
  end

  private

  def key_valid? key
    if key.blank? or not key.kind_of? String
      raise 'key must be valid'
    end
  end

  def key_and_value_valid? key, value
    key_valid? key
    if value.nil?
      raise 'value must be not nil'
    end

  end
end
