class Shop < ApplicationRecord
    belongs_to :station, optional: true

    before_validation :set_instagram_flag

    validates :name, presence: { message: "ショップ名は必須です" }
    validates :is_ai_generated, inclusion: { in: [true, false], message: "AI生成フラグは必須です" }
    validates :is_instagram, inclusion: { in: [true, false], message: "Instagramフラグは必須です" }

    def station_name
        self.station&.name
    end
    
    
    private

  def set_instagram_flag
    if url.present? && url.include?("instagram.com")
      self.is_instagram = true
    else
      self.is_instagram = false
    end
  end

end
