module ApplicationHelper
  def show_flash_notification(type, content)
    content_tag(:div, content, class: "notification is-#{type}")
  end

  def app_title
    @app_title
  end

  def set_title(before: nil, after: nil)
    @app_title = t('app.title')
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title << " | #{after}" unless after.nil?
    @app_title
  end

  def avatar_tag(size: 200, user: nil, **options)
    user ||= current_user

    content_tag :figure, class: 'avatar' do
      if user.avatar.attached?
        image_tag(user.avatar.variant(resize_to_limit: [size, size]), **options)
      else
        url = "https://api.adorable.io/avatars/#{size}/#{user.username}.png"
        image_tag(url, alt: user.name, size: size, **options)
      end
    end
  end

  def field_control(&block)
    content_tag :div, class: 'field' do
      content_tag :div, class: 'control' do
        yield block
      end
    end
  end
end
