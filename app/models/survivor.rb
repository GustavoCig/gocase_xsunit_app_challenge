class Survivor < ApplicationRecord
    validates_inclusion_of :gender, :in => ["male", "female"]
end
