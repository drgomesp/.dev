---
title: "Repository Pattern in Go: Drivers and Portable Code"
date: 2021-01-14T12:41:35-03:00
draft: false
tags:
  - go
  - ddd
  - design-patterns
type: note
---

When writting software in terms of [Domain-Driven Design (DDD)](https://martinfowler.com/bliki/DomainDrivenDesign.html), specifically in the context of Go, there's a common interpretation of the [Repository](https://www.martinfowler.com/eaaCatalog/repository.html) pattern which drives the implementation to something similar to the following code:

```go
type UserRepository interface {
	SaveUser(context.Context, *User) error
	GetUserByID(context.Context, string) (*User, error)
}
```

Now while this works, and it's a good practice to use interfaces in general, this is a bit misleading as it makes it really difficult for `UserRepository` to be portable in terms of infrastructure (think database layer). All specific implementations of the repository will have to duplicate some common code (business-specific code, maybe) which has nothing to do with the internal storage engine used by the repository.

For this particular reason, I generally like to define repositories as concrete types, and introduce a layer of abstraction (**drivers**) that deals with the specific details of each storage engine (pgsql, mysql, even docstore, etc):

```go
type UserDriver interface {
    SaveUser(context.Context, *User) error
	GetUserByID(context.Context, string) (*User, error)
}

type UserRepository struct {
    driver UserDriver
}
```

This allows the repository to be totally agnostic in terms of the storage engine, making it really portable. For convenience, the repository can expose the same API as the driver or even extend it with some more features:

```go
func (r *UserRepository) SaveUser(context.Context, *User) error {}
func (r *UserRepository) GetUserByID(context.Context, string) (*User, error) {}
func (r *UserRepository) GetUserByEmail(context.Context, string) (*User, error) {}
```

So, if your repository contains code which makes use of packages like [`sql/driver`](https://pkg.go.dev/database/sql/driver@go1.15.6), that's the code you should move to a driver implementation.
