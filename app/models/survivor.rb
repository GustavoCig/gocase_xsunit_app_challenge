class Survivor < ApplicationRecord
    validates :name, :age, :gender, :latitude, :longitude, presence: true
    validates :name, uniqueness: true
    validates :age, numericality: {only_integer: true}
    validates_inclusion_of :gender, :in => ["male", "female"]
end
