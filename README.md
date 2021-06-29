# postal-lookup-lambda

Postal code lookup Lambda function in Ruby

## Data Source

Obtain postal code database from [GeoNames](http://www.geonames.org/).

Save files into `./datasets` directory.

## Usage

Invoke the function via API Gateway (expose to the web) or directly.

### JSON Request

```json
{
  "codes": ["US12345", "US67890"],
  "lat": 30.012,
  "lon": -140.789
}
```

Possible options are:

- `codes` – look up the given postal code, `<2-letter-CC>+<postal_code>`; up to two as an array
- `codes` + `lat` & `lon` – geo-coordinates can be specified along with one postal code
- when two locations are given, the distance inbetween is also calculated

### JSON Response

```json
{
  "results": [
    {
      "code": "US12345",
      "name": "Small City",
      "state": "XO",
      "lat": 23.345,
      "lon": 127.407
    },{
      "code": "US12345",
      "name": "Big City",
      "state": "XO",
      "lat": 28.006,
      "lon": 127.516,
    }
  ],
  "distance": 516480
}
```

