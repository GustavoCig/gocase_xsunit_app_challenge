class Params_reader

  # Deals with the processing, sanitizing and usage of the params passed in the
  # GET root request
  def process_fields(params)
    fields = get_url_fields(params["fields"])
    results_per_page = get_limit_of_results_per_page(params["per_page"])
    order_by = define_sorting_attribute(fields)
    page = define_current_page(params["page"], results_per_page)
    survivors = order_by ? Survivor.select(fields).order(order_by).limit(results_per_page).offset(page) : 
                            Survivor.select(fields).order(:name).limit(results_per_page).offset(page)
    return survivors
  end

  # Show, according to number of registers per page,
  # how many pages the register of survivors has
  def show_total_number_of_pages(params)
    message = {}
    total = Survivor.count()
    results_per_page = get_limit_of_results_per_page(params["per_page"])
    number_of_pages = get_num_pages(total, results_per_page)
    message["number of pages"] = number_of_pages
    return message
  end

  # Verifies, comparing with a predefined constant,
  # which parameters are considered valid or not
  def get_invalid_parameters(valid_parameters, parameters)
    invalid_parameters = []
    parameters.each do |key, value|
      if !valid_parameters.include?(key)
        invalid_parameters.push(key)
      end
    end
    return invalid_parameters
  end

  # Displays a message to the user, detailing any and all unused parameters passed in the URL
  def unused_params_warning(valid_params, in_use_params)
    message = {}
    invalid_params = get_invalid_parameters(valid_params, in_use_params)
    if !invalid_params.empty?
      message["warning"] = "Unnecessary/unused parameters sent: " + invalid_params.join(', ')
    end
    return message
  end

  private

  def get_url_fields(url_fields)
    fields = url_fields ? sanitize_fields_params(url_fields) : "*"
    fields = fields.empty? ? "*" : fields
  end

  def get_limit_of_results_per_page(per_page)
    if per_page.to_i != 0
      limit = per_page.to_i
    else
      limit = Survivor.count()
    end
    return limit
  end

  def get_num_pages(total, num_per_page)
    num_pages = total/num_per_page
    if total % num_per_page != 0
      num_pages += 1
    end
    return num_pages
  end

  def define_sorting_attribute(fields)
    if fields.include?("name")
      order_by = :name
    elsif fields.include?("id")
      order_by = :id
    else
      order_by = false
    end
    return order_by
  end

  def define_current_page(url_page, per_page)
    if url_page
      page = url_page.to_i * per_page
    else
      page = 0 * per_page
    end
    return page
  end

    # Cleans parameter 'fields' of any element not found in SurvivorsController::FIELDS
    def sanitize_fields_params(fields)
      valid_fields = []
      fields.split(',').each do |field|
        if Constants::FIELDS.include?(field)
          valid_fields.push(field)
        end
      end
      valid_fields
    end
end