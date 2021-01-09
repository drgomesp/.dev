---
title: "Getting started with OpenGL and Go"
date: 2017-07-12T14:00:00-03:00
draft: false
tags:
  - go
  - opengl
type: note
---
With the recent popularization of Golang, I've decided to show how graphics programming can be done in Go using modern OpenGL techniques. I'll assume you are familiar with the concept of OpenGL and have a general idea of how it works on a higher level.

{{< figure src="/img/posts/getting_started_with_opengl_and_go/1.png" caption="Open Graphics Library (OpenGL) is a cross-language, cross-platform application programming interface (API) for rendering 2D and 3D vector graphics." alt="OpenGL's logo" >}}

### OpenGL context and platform-agnostic APIs

The first thing we need in order to be able to render with OpenGL is an OpenGL context. Now, depending on the platform we're developing for, this can be done in a completely different way - if we're developing for Windows, we'd have to use the win32 API; on Linux, that would be X; and Mac, Cocoa and NSOpenGL. That can be a real nightmare to deal with when you don't have experience with those platform layers.

Also, we'd like to focus on multi-platform development, since that's where Go really shines, and so we're going to use an abstraction library that allows us to create a window with an OpenGL context regardless of the platform layer: GLFW. Now, GLFW was initially created as a C library. However, there are Go bindings available. That essentially means we'll be calling the C library from the Go code. But hey, don't worry: we'll actually be writing pure Go code. The library takes care of the platform-specific details for us.

To start, we need to fetch two packages. First we download GLFW (for installation details or more info, check https://github.com/go-gl/glfw#installation):

```bash
go get -u github.com/go-gl/glfw/v3.2/glfw
```

Then we download the actual OpenGL bindings library:

```bash
go get -u github.com/go-gl/gl/v4.1-core/gl
```

Here, the versions might differ depending on what version of OpenGL your graphics card (and the graphics cards of those who will be targeted by your code) support. For more reference on the versions, check https://github.com/go-gl/gl#usage.

> *We'll use GLFW 3.2 and OpenGL 4.1-core for the rest of this series of articles.*

### Opening a window

Let's start from the basics: we need to call the initialization function of GLFW. You're probably not familiar with this style of code (C-like), where there are no objects and functions are very much stateful, imperative. To do that, you should write something like:

```go
runtime.LockOSThread()
if err := glfw.Init(); err != nil {  
    panic(fmt.Errorf("could not initialize glfw: %v", err)) 
}
```

You shouldn't see any errors at this point. If you do, don't panic.

The first line makes sure that OpenGL won't break. That's because it requires every function call that interfaces with its C library to be called from the main thread. We need to call that to ensure this in Go.

Next, we can specify window hints, which are essentially hints given to the GLFW library regarding the window and its OpenGL context. Let's pass a few basic ones:

```go
glfw.WindowHint(glfw.ContextVersionMajor, 4) 
glfw.WindowHint(glfw.ContextVersionMinor, 1) 
glfw.WindowHint(glfw.Resizable, glfw.True) 
glfw.WindowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile) 
glfw.WindowHint(glfw.OpenGLForwardCompatible, glfw.True)
```

Here we're saying a few number of things:

  - OpenGL context should be compatible with the major version 4 and minor version 1. These are not hard constraints, but the creation of the window will fail if the major version is lower than the hinted one and the same goes for the minor version.
  - Resizable means exactly what you think it does.
  - OpenGL profile in this case should be core.
The final hint is very important. When compiling on Mac and using this specific version of OpenGL, it's a required hint for it to work.

To read more about window hints and other configuration, check http://www.glfw.org/docs/latest/window_guide.html.

We're almost there! Now that we've passed the required hints to GLFW, we can finally call the function that actually creates the window, like so:

```go
win, err := glfw.CreateWindow(800, 600, "Hello world", nil, nil)
if err != nil {  
    panic(fmt.Errorf("could not create opengl renderer: %v", err))
}
```

### Preparing for OpenGL

After creating the window, we just need a few more steps:

``` go
win.MakeContextCurrent()
```

MakeContextCurrent is what actually creates the OpenGL context within the platform window that gets created by GLFW. Now, we're ready to open the window. Usually, for that, we'll write a simple loop:

```go
for !win.ShouldClose() {
   win.SwapBuffers()
   glfw.PollEvents()
}
```

Here, we're looping as long as the window should be opened, and we do basic operations:

  - Swap buffers, which swaps the front and back buffers of the window(one used for rendering, the other for drawing).
  - Poll events, which actually allows us to catch events such as the close button, so that the window can close (and, of course, all other events, including input events)

The final result should be a beautiful black window:

{{< figure src="/img/posts/getting_started_with_opengl_and_go/2.png" alt="Window with a Black Screen" >}}

Now that we have an OpenGL context ready window, let's actually initialize OpenGL and call a simple function to clear the screen to a nice blue color (this code should be placed before our window loop):

```go
if err := gl.Init(); err != nil {
	panic(err)
}
```

And right after we initialize OpenGL, let's clear the screen:

```go
gl.ClearColor(0, 0.5, 1.0, 1.0)
```

And for that to work properly, we need to adjust our loop, with an extra OpenGL function call:

```go
for !win.ShouldClose() {
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	win.SwapBuffers()
	glfw.PollEvents()
}
```

And the result should be a blue screen, just like this one:

{{< figure src="/img/posts/getting_started_with_opengl_and_go/3.png" alt="Window with a Blue Screen" >}}

Here's the full code:

```go
package main

import (
	"fmt"
	"runtime"

	"github.com/go-gl/gl/v4.1-core/gl"
	"github.com/go-gl/glfw/v3.2/glfw"
)

const (
	windowWidth  = 960
	windowHeight = 540
)

func main() {
	runtime.LockOSThread()
	if err := glfw.Init(); err != nil {
		panic(fmt.Errorf("could not initialize glfw: %v", err))
	}

	glfw.WindowHint(glfw.ContextVersionMajor, 4)
	glfw.WindowHint(glfw.ContextVersionMinor, 1)
	glfw.WindowHint(glfw.Resizable, glfw.True)
	glfw.WindowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile)
	glfw.WindowHint(glfw.OpenGLForwardCompatible, glfw.True)

	win, err := glfw.CreateWindow(windowWidth, windowHeight, "Hello world", nil, nil)
	if err != nil {
		panic(fmt.Errorf("could not create opengl renderer: %v", err))
	}

	win.MakeContextCurrent()
	if err := gl.Init(); err != nil {
		panic(err)
	}

	gl.ClearColor(0, 0.5, 1.0, 1.0)

	for !win.ShouldClose() {
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		win.SwapBuffers()
		glfw.PollEvents()
	}
}
```

I hope you enjoyed this article, and that it was helpful to you in some way. We're going to be looking at drawing some basic primitive geometries in the next article. See you then!

---
