---
title: "Beyond the Basics of Go: HTTP Handlers"
date: 2021-01-07T11:42:12-03:00
draft: true
---

## The `http.Handler` and `http.HandlerFunc` types

The Go standard library defines two main components for dealing with incoming HTTP requests: the [`http.Handler`](https://golang.org/pkg/net/http/#Handler) type and the [`http.HandlerFunc`](https://golang.org/pkg/net/http/#HandlerFunc) type. 

While `http.Handler` is an actual interface,

```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}
```

 `http.HandlerFunc`, on the other hand, is just a type definition,

```go
type HandlerFunc func(ResponseWriter, *Request)
```

which is even more flexible and allows the usage of ordinary functions as  HTTP handlers, as long as they respect that signature. 

The way you implement your handler is really dependent on what you want to achieve and also the limitations of each approach. 

Using the `http.Handler` interface requires you to define a type and implement it in order for it to be treated as a Handler. Here's an example:

```go
type foo struct {}

func (h *foo) ServeHTTP(w http.ResponseWriter, req *http.Request) {
    w.WriteHeader(http.StatusOK)
}
```

With the `http.HandlerFunc` type things get even easier, and you can simply define a function that respects the required signature of an `http.HandlerFunc`. Here's an example, where `Foo` is a valid HTTP handler:

```go
func Foo(w http.ResponseWriter, req *http.Request) {}
```

## Serving HTTP requests

Once you have a valid handler, you can serve HTTP requests by writing very simple code (specifically, making use of the [`http.Handle`](https://golang.org/pkg/net/http/#Handle), [`http.HandleFunc`](https://golang.org/pkg/net/http/#HandleFunc) and the [`http.ListenAndServe`](https://golang.org/pkg/net/http/#ListenAndServe) functions), which might look like this:

```go
http.Handle("/foo", new(foo)) // Assuming you implemented the http.Handler interface
http.HandleFunc("/foo", Foo) // Assuming you defined Foo as an http.HandlerFunc

log.Fatal(http.ListenAndServe(":8080", nil))
```

Both `http.Handle` and `http.HandleFunc` functions will actually add the given handlers to the what's called the [`http.DefaultServeMux`](https://golang.org/src/net/http/server.go?s=97511:97566#L2238), internally defined by the `net/http` package. 

I strongly advise referring to the source code for the documentation, which describes `http.DefaultServeMux` as an [HTTP request multiplexer](https://golang.org/src/net/http/server.go?s=97511:97566#L2187).

If you call `http.ListenAndServe` and pass `nil` as the handler argument, it will internally use `http.DefaultServeMux`. 

## The `http.ServeMux` struct






