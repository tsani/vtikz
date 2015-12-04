vTikZ
=====

Drawing is fun with TikZ, but animating is more fun with vTikZ.

vTikZ is a TikZ framework for creating animations. It provides useful macros
for creating sequences of frames and interpolating them. The output is
essentially a flipbook, a PDF with one page per frame. A script is provided to
convert flipbooks into bona fide videos by splitting the PDF into one raster
image per frame and concatenating these frames into a video with ffmpeg.

Usage
=====

vTikZ works best with the `article` documentclass.

Start by importing vTikZ.

```tex
\usepackage{vtikz}
```

A number of different environments are defined. The most basic is `basicframe`.
It will simply cause a pagebreak when it ends. This is essential since each
frame is one page.

```tex
\begin{basicframe}
    This is one frame.
\end{basicframe}

\begin{basicframe}
    This is another frame.
\end{basicframe}
```

Drawing
-------

Just putting text isn't very interesting. How about we draw something with
TikZ? The `tikzframe` environment sets up a basic `tikzpicture` environment for
you to draw in. The coordinate system is such that the origin is at the
top-left corner of the page, and values of _y_ are _decreasing_ as you move
down on the page. This is in contrast with the coordinate system of many
desktop environments, but is consistent with the standard mathematical
coordinate system works.

Note, the default vTikZ frame size is ten inches by ten inches, and the TikZ
unit length is set to one inch. The following will print "Hello world!" in huge
font in the middle of the frame.

```tex
\begin{tikzframe}
    \node at (5, -5) {\huge Hello world!}
\end{tikzframe}
```

Animation
---------

Now that we can draw on frames, let's animate! 

To describe a sequence of frames, use use `tikzmultiframe` environment, which
repeats the given text inside a `tikzframe` a given number of times. Within a
`tikzmultiframe` environment, two important macros are available:

 * `\f` gives the current frame number
 * `\fprogress` gives the progres of the animation as a fraction of the number
   of frames elapsed.

Also, the `\fmax` macro will expand to the number of frames given as the
parameter to `tikzmultiframe`. Hence, `\fprogress` is equal to `\f/\fmax`.

Let's draw "Hello world!" at the bottom of the frame and move it up to the top
of the frame over the course of two seconds. Currently, vTikZ requires you to
work directly with frame counts instead of times. Thus, it's essential to know
that the default vTikZ framerate is 30 frames per second.

```tex
\begin{tikzmultiframe}{60}
    \node at (5, {-8 + 6*\fprogress}) {\huge Hello world!}
\end{tikzmultiframe}
```

The macro `\fprogress` will start out as `1/60` and will finally reach `60/60`.
TikZ has a math engine that will evaluate this fraction, multiply it by our
desired displacement `6` and compute the `y` position of the text. The result
is that the text will move from the bottom of the frame to the top of the frame
over the course of two seconds in a linear fashion.

Nonlinear interpolation
-----------------------

It's possible to achieve more complex interpolation behaviours by defining
_interpolation functions_. These are maps `[0, 1] -> [0, 1]` that are used to
redefine the `\fprogress` macro. As such, our drawing code can be pasted into
an interpolation environment unchanged and automatically have its movement
interpolated in a new way.

Let's define an interpolation function that will _ease_ the movement by
starting out slow, accelerating, and finally slowing down.
From playing around in Wolfram Alpha, we find that
`(20*x/pi - sin(20x/pi))/(2pi)` seems to do the job.
Now we just need to write this function as a LaTeX macro

```tex
\newcommand{\EaseInterpolate}[1]{(20.0*#1/pi - sin(20.0*#1/pi r))/(2*pi)}
```
pass it to the `interpolate` environment
```tex
\begin{tikzmultiframe}{60}
    \begin{interpolate}{\EaseInterpolate}
        \node at (5, {-8 + 6*\fprogress}) {\huge Hello world!}
    \end{interpolate}
\end{tikzmultiframe}
```
and watch as our text elegantly slides across the page !

`\EaseInterpolate` is available by default in vTikZ. New interpolation
functions are welcome in pull requests.

Video rendering
===============

A simple script is provided to render flipbooks to videos using ImageMagick and
ffmpeg. Its usage is very simple.

```bash
./tovideo.sh flipbook.pdf video.mp4
```
