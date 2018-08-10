# Introduction

REST API developed as part of the internship selection process from Gocase.
API handles the registration of `Survivors` in the event of an alien invasion, being capable of registering, updating, flagging a survivor as abducted and showing percentage of safe and abducted survivors, among few other things.

# Requirements
---
 * Ruby 2.5.1
 * Rails 5.2.1
 * MySQL 5.7.23
 
# Structure
---
### Model

A single model is used in this API, being the *__Survivors__* model, which is composed by the following fields:
* `id`: Integer
* `name`: String
* `age`: Integer
* `gender`: String
* `latitude`: decimal
* `longitude`: decimal
* `number_of_flags`: integer
* `is_abducted`: boolean

`number_of_flags` serves as a control variable, which, depending on it's value, `is_abducted` will be set to true.
```ruby
if number_of_flags >= 3
    is_abducted = true
end
```

`longitude` and `latitude` describe the location of a Survivor and are the only attributes able to be updated. 

### Endpoints
 * `GET /survivors` 
    Displays to the user a listing of all registered survivors, alongside all their parameters.
    Query can be filtered and paginated by adding the following parameters to the URL:
    - `fields`
       Can be set as any combination of fields pertaining to the model survivors, it's values are going to determine which fields are shown by the query
Example: `survivors?fields=id,name,is_abducted`
    - `per_page`
       Describes how many entries are displayed per page of the query.
       Example: `survivors?per_page=10`
    - `page`
        Operates as a cursor, describing which page the user is currently in.
        Example: `/survivors?page=2`
* `POST /survivors`
    By passing a JSON with all the necessary information of a survivor (`name`, `age`, `gender`, `latitude` and `longitude`) a new "survivor" is created and saved in the database. `id` doesn't need to be passed as a parameter, since it defaults to an auto incrementing value. Same can be said for `number_of_flags` and `is_abducted`, defaulting to 0 and false respectively.
* `GET /survivor/:id`
    Simply returns in a JSON all the data of the survivor which has id `:id`.
* `PUT/PATCH /survivors/:id`
    Endpoint used to update a survivor's latitude and longitude, displaying a JSON showing the change of between the old and new values.
* `DELETE /survivors/:id`
    Simply deletes the user with the aforementioned `:id`.
* `GET /survivors/statistics`
    Returns a JSON containing the percentage of abducted and non-abducted survivors.
* `GET /survivors/:id/flag`
    Flags the survivor with the aforementioned `:id` as abducted, needing 3 flags to be truly marked as being abducted.
    Despite the syntax of this endpoint going against standard REST practices, I thought the overall simplicity of sending a single GET request would be positive, considering how this is one of the main functionalities of the API and also how trying to update a survivor's `number_of_flags` through a POST request would be, both more complicated and also require treatment to guarantee that the attribute is only being incremented by a value of 1 and not more.


### To Be Improved
* Improve the exception handling.
* Add Unit Testing and Integration Testing
* Improve sanitization and handling of URL parameters for queries
* Better refactor and modularization of the code, specially in the services