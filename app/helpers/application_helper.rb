module ApplicationHelper
  def get_name(u)
    name = u.name.to_s.length == 0 ? u.email.split("@").first : u.name rescue "¯\_(ツ)_/¯"
    name.titleize
  end

  def get_name_from_player_id(uid)
    u = Player.find(uid)
    return get_name(u)
  end
end
