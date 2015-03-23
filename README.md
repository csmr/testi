Testi
=====
A simple test framework, its as easy as throwing code and failing it yourself.
Because sometimes, you just wanna test stuff without all the clutter and noise from other frameworks.
Testi aims to be clear and shows you your own code.

Usage:
Create a testi directory in your project, make a few of `.rb` test files in it and:
```bash
testi
```
Watch the magic!

Test:
```ruby
ary = []

unless ary.empty?
  fatal 'For some odd reason a new array is not #empty?'
end
```

The functions are modelled after the Golang `test` package, specifically the ones found on `T`
