class Admin < ApplicationRecord
  has_many :posts
  has_one_attached :avatar

  def instagram_url
    # Find the hash with "platform": "linkedin" and return its "url"
    social_links_hash = social_media_links.is_a?(Array) ? social_media_links.find { |link| link['platform'] == 'instagram' } : nil
    social_links_hash ? social_links_hash['url'] : nil
  end
  def instagram_url=(new_url)
    current_links = social_media_links.is_a?(Array) ? social_media_links : []
    existing_link_index = current_links.find_index { |link| link['platform'] == 'instagram' }

    if new_url.present?
      if existing_link_index
        current_links[existing_link_index]['url'] = new_url
      else
        current_links << { 'platform' => 'instagram', 'url' => new_url }
      end
    else
      current_links.delete_at(existing_link_index) if existing_link_index
    end
    self.social_media_links = current_links
  end

  # --- LinkedIn URL ---
  def find_social(social)
    # Find the hash with "platform": "linkedin" and return its "url"
    social_links_hash = social_media_links.is_a?(Array) ? social_media_links.find { |link| link['platform'] == social } : nil
    social_links_hash ? social_links_hash['url'] : nil
  end

  def linkedin_url=(new_url)
    # Ensure social_media_links is an array before modification
    current_links = social_media_links.is_a?(Array) ? social_media_links : []
    # Find the index of an existing LinkedIn link
    existing_link_index = current_links.find_index { |link| link['platform'] == 'linkedin' }

    if new_url.present? # If a URL is provided, add/update it
      if existing_link_index # Update existing link
        current_links[existing_link_index]['url'] = new_url
      else # Add new link
        current_links << { 'platform' => 'linkedin', 'url' => new_url }
      end
    else # If new_url is blank, remove the link
      current_links.delete_at(existing_link_index) if existing_link_index
    end
    # Assign the modified array back to the attribute
    self.social_media_links = current_links
  end

  # --- Twitter URL (Repeat pattern for other platforms) ---
  def twitter_url
    social_links_hash = social_media_links.is_a?(Array) ? social_media_links.find { |link| link['platform'] == 'twitter' } : nil
    social_links_hash ? social_links_hash['url'] : nil
  end

  def twitter_url=(new_url)
    current_links = social_media_links.is_a?(Array) ? social_media_links : []
    existing_link_index = current_links.find_index { |link| link['platform'] == 'twitter' }

    if new_url.present?
      if existing_link_index
        current_links[existing_link_index]['url'] = new_url
      else
        current_links << { 'platform' => 'twitter', 'url' => new_url }
      end
    else
      current_links.delete_at(existing_link_index) if existing_link_index
    end
    self.social_media_links = current_links
  end

end
