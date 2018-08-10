class Survivor < ApplicationRecord
    validates :name, :age, :gender, :latitude, :longitude, presence: true
    validates_uniqueness_of :id, :name
    validates :age, numericality: {only_integer: true}
    validates_inclusion_of :gender, :in => ["male", "female"]
end
