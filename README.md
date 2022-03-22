# Search Engine

To run the service, open rails console and run following code;

```SearchEngine.new(service_name, geolocation).call```

#### For Example

```SearchEngine.new('Massör', 'Massör').call```

This will return locations that are matched with similarity above 70%
