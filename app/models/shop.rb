class Shop < ApplicationRecord
    belongs_to :station

    validates :name, presence: { message: "ショップ名は必須です" }
    validates :is_ai_generated, presence: { message: "AI生成フラグは必須です" }
    validates :is_instagram, presence: { message: "Instagramフラグは必須です" }

    def station_name
        self.station.name
    end
end
