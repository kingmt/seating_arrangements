# **Seating Arrangements**
--------------
## **Problem Definition**

Develop an API that exposes CRUD endpoints to manage “Valid Seating Arrangements” around circular tables.

**Valid Seating Arrangements:**
Tables are “circular” and should be structured that way in your code.
The “People” that sit at your tables need only have a name and age properties.
A seating arrangement is valid under the following conditions:

* For any two people sitting next to one another, they must be within a 5 year age range.
  * Ex: Age 30 -- Age 38 is invalid because Math.Abs(38 - 30) > 5
  * Ex: Age 30 -- Age 35 is valid because Math.Abs(35 - 30) <= 5

* A person cannot sit in between two people that are older than them.
  * Ex: Age 20 -- Age 17 -- Age 22 is invalid because 20 > 17 && 22 > 17.
  * Ex: Age 20 -- Age 17 -- Age 15 is valid because Age15 < Age17 < Age20


There is no limit to the amount of people who sit at a table so long as the above constraints are met.

**Requirements:**
Build a Restful API in Rails that exposes CRUD endpoints, so http requests can be made to the server to perform the following operations:

**TABLE**

* Create a new circular table
* Read the current state of circular table (i.e. the seating arrangement)
* Update what people are sitting at the table (including their order)
* Delete a table

**PERSON**

* Create a new person with the required fields name and age.
* Read the current state of a person
* Update a person’s name or age properties
* Delete a person from existence! :)

Appropriately prevent updates of the circle-table or person if that update would violate a “Valid Seating Arrangement” as defined above.

Respond with helpful error messages when updates cannot be performed.


### **REST API**

#### **Tables**

* **Create Table**
  * POST /api/table
  * creates a new table and returns a JSON object containing the table's information
  * Params:
    none
  * Response:
```json
{
  "id": 2,
  "seats": []
}
```
* **Get Table**
  * GET /api/tables/:id
  * returns a JSON object listing all the people at the table with their positions
  * Params:
    id of the table
  * Response:
```json
{
  "id": 2,
  "seats": [{"id": 1, "name": "Matt", "age": 20, "can_be_unseated": false},
            {"id": 2, "name": "John", "age": 20, "can_be_unseated": false},
            {"id": 3, "name": "Paul", "age": 22, "can_be_unseated": true }]
}
```
* **Delete a Table**
  *   DELETE /api/tables/:id
  *   returns a 204 and unseats all the people who were at the table
  * Params:
     id of the table
  * Response:
    empty body with a status code of 204

* **Seat an Entire Table**
  * Update all people at the table required param is a list of all people to be seated at the table in position order
  * PUT /api/tables/:id
  * Required Params:
    table id in the url
    an array of the person ids to be seated in the order to be seated
    `{"people": [ 22, 13, 45, 1 ]}`
  * Success Response:
    same as GET /api/table/:id
  * Error Response:
    When some of the people are already seated at a different table
    `{"errors": "Michael, Sam, and Sara have already been seated at another table"}`
    When resulting table would be invalid
    `{"errors": "Unable to seat those people in that order"}`

#### **People**
* **Create a Person**
  *  POST /api/people
  * Required Params:
    `{"person":{"name": "Joe", "age": 27}}`
  * Response:
```json
Seated:
       {
        "id": 12,
        "name": "Joe",
        "age": 27,
        "seated": true,
        "seated_at_table": 2
       }
Unseated:
       {
        "id": 13,
        "name": "Sam",
        "age": 28,
        "seated": false,
        "seated_at_table": null
       }
Error:
      {"errors": ["Age can't be blank"]}

```

* **Get All People**
  * GET /api/people
  * returns JSON object of all people in the system
  * Params: none
  * Response:
```json
      [{
        "id": 12,
        "name": "Joe",
        "age": 27,
        "seated": true,
        "seated_at_table": 2
       },
       {
        "id": 13,
        "name": "Sam",
        "age": 26,
        "seated": false,
        "seated_at_table": null
       }]
```

* **Get the Information About a Single Person**
  * GET /api/people/:id
  * returns JSON object of that person's information
  * Params:
    id of the person in the url
  * Success Response:
    same as the response from creating a person
  * Error Response:
    404 status code when the person does not exist

* **Update a Person**
  * PUT /api/people/:id
  * update the information on a person
  * Restrictions:
    A seated person cannot be updated
  * Required Params:
    name or age
    `{"person":{"name": "Joe"}}`
  * Success Response:
    same as the response from creating a person
  * Error Response:
    404 status code when the person does not exist
    422 `{"errors": "Cannot update a seated person"}`

* **Delete a Person**
  * DELETE /api/people/:id
  * removes the person from the system and responds with a status code of 204
  * Restrictions:
    A seated person cannot be deleted
  * Params:
    id of the person in the url
  * Success Response:
    empty response with status code 204
  * Error Response:
    404 status code when the person does not exist
    422 `{"errors": "Cannot delete a seated person"}`

#### **Seats**
Adding and removing people from tables

* **Add a Person to a Table**
  * POST /api/tables/:table_id/seats/
  * Optional param of the position of the person, if no  position is given the system will attempt to add the  person in the first valid position
  * Required Params:
    table id in the url
  * Optional Params
  ` {"position": 3}`
  * Success Response:
    same as GET /api/table/:id
  * Error Response for attempted auto placement:
    `{ "errors": "Person cannot be seated" }`
  * Error Response when position was given
    `{ "errors": "Person cannot be seated at that position" }`

* **Change a person's position at the table**
  * PUT /api/tables/:table_id/seats/:id
  * returns a JSON object listing all the people at the table  with their positions or an error message
  * Required Params:
    table id and seat id in the url
  ` {"position": 3}`
  * Success Response:
    same as GET /api/table/:id
  * Error Response:
   `{ "errors": "Person cannot be seated at that position" }`

* **Remove a person from a table**
  * DELETE /api/tables/:table_id/seats/:id
  * Required Params:
    table id and seat id in the url
  * Success Response:
    same as GET /api/table/:id
  * Error Responses for invalid seat
    `{ "errors": "Seat does not exist" }`
  * Error Responses for ineligible deletion
    `{ "errors": "Cannot remove the seat, the table would be invalid" }`








