Rails.application.config.content_security_policy do |p|
  p.font_src    :self, :https, :data
  p.img_src     :self, :https, :data
  p.object_src  :none
  p.style_src   :self, :https, :unsafe_inline
  p.script_src :self, :https, :unsafe_inline

  p.default_src :self, :https

  if Rails.env.development?
    p.connect_src :self, :https, 'http://localhost:3000'
  else
    p.connect_src :self, 'https://www.akinyele.ca'
  end
end

