class Flag_service

    def increment_survivor_flags(survivor)
      survivor.number_of_flags += 1
    end

    def update_survivor_status(survivor)
      if survivor.number_of_flags >= 3
        survivor.is_abducted = true
      end
    end

end