module Constants
    # Controller constants definition
    # FIELDS defined as a means of keeping track of which values are actual fields
    # in the survivor's model
    FIELDS = ["id", "name", "age", "gender", "latitude", "longitude", "number_of_flags",
                "is_abducted", "created_at", "updated_at"]

    # Both params are defined to highlight all the normal/valid parameters to be
    # forwarded during their respective actions
    CREATE_PARAMS = ["name", "age", "gender", "latitude", "longitude", "survivor", 
                        "id", "controller", "action"]
    UPDATE_PARAMS = ["latitude", "longitude", "survivor", "id", "controller", "action"]
end