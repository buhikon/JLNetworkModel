# JLNetworkModel
A model class which parse JSON data and save into own property.


## usage

1. Create a new class which extends JLNetworkModel.
2. Code properties whose name is same as the API spec.
3. When you receive JSON network response, use below code to create a new instance.

```
MyObject *obj = [[MyObject alloc] initWithNetworkDict:dict];
```

4. Then, dictionary data will be initialized into your custom object.