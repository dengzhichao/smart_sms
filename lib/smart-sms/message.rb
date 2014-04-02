module SmartSMS
  module Message
    extend self

    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    def send phone, content, options = {}
      if options[:method] == :general
        options[:code] = content
        message = parse_content options
        opts[:tpl_id] ||= SmartSMS.config.template_id
        opts.merge!({mobile: phone, tpl_value: message})
        Request.post 'sms/tpl_send.json', opts
      else
        Request.post 'sms/send.json', mobile: phone, text: content, extend: options[:extend]
      end
    end

    def find_by_sid sid
      Request.post 'sms/get.json', sid: sid
    end

    def find options = {}
      find_messages 'sms/get.json', options
    end

    def get_black_word text = ''
      Request.post 'sms/get_black_word.json', text: text
    end

    def get_reply
      find_messages 'sms/get_reply.json', options
    end

    private

    # 批量查短信, 参数:
    #   start_time: 短信提交开始时间
    #   end_time: 短信提交结束时间
    #   page_num: 页码，从1开始
    #   page_size: 每页个数，最大100个
    #   mobile: 接收短信的手机号
    #
    def find_messages api, options = {}
      options[:start_time] = parse_time options[:start_time]
      options[:end_time] = parse_time options[:end_time]
      options[:page_num] ||= SmartSMS.config.page_num
      options[:page_size] ||= SmartSMS.config.page_size
      Request.post api, options
    end

    def parse_time time = ''
      if time.present? && time.is_a?(Time)
        time.strftime DATETIME_FORMAT
      else
        ''
      end
    end

    def parse_content options = {}
      options[:code] ||= ''
      options[:company] ||= SmartSMS.config.company
      SmartSMS.config.template_value.map do |key|
        "##{key.to_s}#=#{options[key]}"
      end.join('&')
    end
  end
end