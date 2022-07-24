Hello 


Simple flutter sqlite dbhelper

call like this 

```dart
  DbHelper helper = DbHelper();
    helper
        .initializeDb()
        .then((result) => helper.getTodos().then((result) => todos = result));


```
