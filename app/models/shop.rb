class Shop < ApplicationRecord
    belongs_to :station

    def station_name
        self.station.name
    end
end
