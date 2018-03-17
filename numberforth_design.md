#  LHVM

## NumberForth Language Design
Everything returns a number.
StoryForth is for strings.

#### Multiplex example
```
2 BIND #duration
sample_elapsed_time BIND $time
200 3 2 #duration <- parameters for ADSR: hidden in collapsed mode.
adsr <- makes it a one-shot value
sample_axis_cycle
0 BIND $offset; <- offset, initially set to zero
// this is a generic Number receptor that you have to name, and set a default value.
add add <- take the sawtooth of elapsed + offset + axis_cycle
48839 2342.3243 2342 23423.42324 <- parameters for sawtooth: hidden by default
sawtooth <- sawtooth of one-shot time
highpass <- squarewave of sawtooth
// at this point, we have a single wall that moves along the axis and stops
// I want the user to be able to enter the ops in this way, so that they can build
// the initial animation, and then multiplex it.

// new function for combinator that adds 1/3 of current value on stack to next value on stack.
sample: elapsed_time
1 #duration 10   <- parameters for multiplex: hidden in collapsed mode.
          ( every one second, start a 2-second run, ten loops total)
          <- I need some clever way of referencing the ADD word, for the combinator
          <- I need some way of referencing the TIME variable
: MULTIPLEX add-third $time $offset ; <- reduces down to a single value
          <- overrides elapsed_time sample with multiplex_value
          <- overrides offset sample with multiplex_offset
          <- somehow targetted to elapsed_time value, NOT current stack valuecurrent
          <- need to configure start value and number of iterations
          <- need to configure the combinator function, add
          -- runs all iterations in parallel, and reduces the result, via combinator
          -- passes in its properties, which override the target sample values
          -- in the UI: it examines the next value on the stack, and recursively goes
             through its call stack, searching for Receptors, and presenting these to
             the user to select from.
          -- FUTURE: select from any valid 2-arity combinator functions
             This function could be a function of your own, such as if you want to
             include clamping or attenuations that accept the multiplex variables.
             Perhaps the mutliplex object contains its own substack for specifying
             the combinator?
abs <- prevent the result from going negative
3
add <- raise the result up 3 units, so it looks better.
```

### How do the users enter objects, functions, and values on the stack?

Users can enter new stack objects, functions, and values in one of two ways:

1. typing the WORD into the stack directly
    * the WORD can be clicked in the node outline, to make its properties appear for editing.
2. Dragging an object into the outline view, which will add it to the stack at the specified location
    * the stack will be place in an invalid state, until the user enters enough words

LHVM will have an embedded subset-of-forth runtime for creating the sampler function.


### With the above example, how would I multiplex over the other axis?
This would, for example, create a cool gridwork effect.

### What do we need to build to make this work?
* LHVM needs to be able to "learn" words, that can call external functions... doing this will allow users to write their own schemas
* We need a way to wrap up properties and substacks within an object
* We need a way to call the external functions from the runtime
* LHVM needs to display the AST, with nested links
* LHVM needs to display the text source, in hybrid mode
* LHVM needs to display the text souce, in full form--this can also be used to serialize the sample program.
  * LHVM will need to deal with converting strings to Doubles, and vice versa
  
  We need to convert a string to an AST to an outline, and back again.
  We need to validate the stack, and show errors where it's not valid.
  
  ### Can parameter binding be accomplished through parameters on the stack?


## Comparing LHVM to Forth
The "Forth disk" is analagous to LHVM's sample buffer.

## Implementation
A "dictionary entry" is a struct, which is associated with a given symbol.

# Question: do we implement NumberForth, or actual Forth?
What will give me a working product most quickly?
What is the most extensible for my users?

