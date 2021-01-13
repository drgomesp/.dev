---
title: "Go Package Design Tips : Custom Type Enums"
date: 2021-01-13T17:09:04-03:00
draft: false
tags:
  - go
type: note
---

When writing a Go package that abstracts some *known domain*, you might come across the situation of having to deal with predefined values that call for using enums. 

Go doesn't have enums, so the idiomatic way would be to use constants (`iota`, optionally). For example, one could define the different statuses of something in the following way:

```go
const (
	StatusPending  = "pending"
	StatusActive   = "active"
	StatusInactive = "inactive"
)

type Something struct {
	Status string
}
```

While this works generally fine and its not a bad solution, what I usually prefer is to rely on custom type definitions, like the example below:

```go
type SomethingStatus = string

const (
	StatusPending  SomethingStatus = "pending"
	StatusActive                   = "active"
	StatusInactive                 = "inactive"
)

type Something struct {
	Status SomethingStatus
}

```

I believe this way, the code becomes a more expressive and more flexible, especially considering the perks of defining your own types.
